{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.environment.memoryAllocator;

  # The set of alternative malloc(3) providers.
  providers = {
    graphene-hardened = {
      description = ''
        Hardened memory allocator coming from GrapheneOS project.
        The default configuration template has all normal optional security
        features enabled and is quite aggressive in terms of sacrificing
        performance and memory usage for security.
      '';

      libPath = "${pkgs.graphene-hardened-malloc}/lib/libhardened_malloc.so";
    };

    graphene-hardened-light = {
      description = ''
        Hardened memory allocator coming from GrapheneOS project.
        The light configuration template disables the slab quarantines,
        write after free check, slot randomization and raises the guard
        slab interval from 1 to 8 but leaves zero-on-free and slab canaries enabled.
        The light configuration has solid performance and memory usage while still
        being far more secure than mainstream allocators with much better security
        properties.
      '';

      libPath = "${pkgs.graphene-hardened-malloc}/lib/libhardened_malloc-light.so";
    };

    jemalloc = {
      description = ''
        A general purpose allocator that emphasizes fragmentation avoidance
        and scalable concurrency support.
      '';

      libPath = "${pkgs.jemalloc}/lib/libjemalloc.so";
    };

    mimalloc = {
      description = ''
        A compact and fast general purpose allocator, which may
        optionally be built with mitigations against various heap
        vulnerabilities.
      '';

      libPath = "${pkgs.mimalloc}/lib/libmimalloc.so";
    };

    scudo =
      let
        platformMap = {
          aarch64-linux = "aarch64";
          x86_64-linux = "x86_64";
        };

        systemPlatform =
          platformMap.${pkgs.stdenv.hostPlatform.system}
            or (throw "scudo not supported on ${pkgs.stdenv.hostPlatform.system}");
      in
      {
        description = ''
          A user-mode allocator based on LLVM Sanitizer’s CombinedAllocator,
          which aims at providing additional mitigations against heap based
          vulnerabilities, while maintaining good performance.
        '';

        libPath = "${pkgs.llvmPackages.compiler-rt}/lib/linux/libclang_rt.scudo_standalone-${systemPlatform}.so";
      };
  };

  providerConf = providers.${cfg.provider};

  # An output that contains only the shared library, to avoid
  # needlessly bloating the system closure
  mallocLib =
    pkgs.runCommand "malloc-provider-${cfg.provider}"
      rec {
        allowSubstitutes = false;
        libName = baseNameOf origLibPath;
        origLibPath = providerConf.libPath;
        preferLocalBuild = true;
      }
      ''
        mkdir -p $out/lib
        cp -L $origLibPath $out/lib/$libName
      '';

  # The full path to the selected provider shlib.
  providerLibPath = "${mallocLib}/lib/${mallocLib.libName}";
in

{
  options = {
    environment.memoryAllocator.provider = lib.mkOption {
      default = "libc";

      description = ''
        The system-wide memory allocator.

        Briefly, the system-wide memory allocator providers are:

        - `libc`: the standard allocator provided by libc
        ${lib.concatStringsSep "\n" (
          lib.mapAttrsToList (
            name: value: "- `${name}`: ${lib.replaceStrings [ "\n" ] [ " " ] value.description}"
          ) providers
        )}

        ::: {.warning}
        Selecting an alternative allocator (i.e., anything other than
        `libc`) may result in instability, data loss,
        and/or service failure.
        :::
      '';

      type = lib.types.enum ([ "libc" ] ++ lib.attrNames providers);
    };
  };

  config = lib.mkIf (cfg.provider != "libc") {
    environment.etc."ld-nix.so.preload".text = ''
      ${providerLibPath}
    '';

    security.apparmor.includes = {
      "abstractions/base" = ''
        r /etc/ld-nix.so.preload,
        r ${config.environment.etc."ld-nix.so.preload".source},
        include "${
          pkgs.apparmorRulesFromClosure {
            baseRules = [ "mr $path/lib/**.so*" ];
            name = "mallocLib";
          } [ mallocLib ]
        }"
      '';
    };

    # Legacy (LLVM < 13) Scudo uses CamelCase options.
    # Standalone (LLVM >= 13) Scudo uses snake_case options.
    # NixOS switched in 25.11: https://github.com/NixOS/nixpkgs/pull/444605
    warnings =
      let
        scudoOpts = config.environment.variables.SCUDO_OPTIONS;

        legacyOptionNames = [
          "QuarantineSizeKb"
          "QuarantineChunksUpToSize"
          "ThreadLocalQuarantineSizeKb"
          "DeallocationTypeMismatch"
          "DeleteSizeMismatch"
          "ZeroContents"
        ];

        # Check which legacy options are in SCUDO_OPTIONS,
        # so we can warn the user about the change.
        legacyOptionsUsed = lib.lists.filter (opt: lib.strings.hasInfix opt scudoOpts) legacyOptionNames;
      in
      lib.optional
        (
          config.environment.variables ? SCUDO_OPTIONS && cfg.provider == "scudo" && legacyOptionsUsed != [ ]
        )
        ''
          environment.variables.SCUDO_OPTIONS: ${lib.concatStringsSep ", " legacyOptionsUsed} is/are no longer valid Scudo options.
          Use snake_case instead of CamelCase: https://llvm.org/docs/ScudoHardenedAllocator.html#options
        '';
  };

  meta = {
    maintainers = [ ];
  };
}
