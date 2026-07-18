/*
  Manages /etc/nix/nix.conf.

  See also
   - ./nix-channel.nix
   - ./nix-flakes.nix
   - ./nix-remote-build.nix
   - nixos/modules/services/system/nix-daemon.nix
*/
{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    literalExpression
    mapAttrsToList
    mkAfter
    mkIf
    mkOption
    mkRenamedOptionModuleWith
    optionals
    systems
    types
    ;

  cfg = config.nix;

  nixPackage = cfg.package.out;

  defaultSystemFeatures = [
    "nixos-test"
    "benchmark"
    "big-parallel"
    "kvm"
  ]
  ++ optionals (pkgs.stdenv.hostPlatform ? gcc.arch) (
    # a builder can run code for `gcc.arch` and inferior architectures
    [ "gccarch-${pkgs.stdenv.hostPlatform.gcc.arch}" ]
    ++ map (x: "gccarch-${x}") (
      systems.architectures.inferiors.${pkgs.stdenv.hostPlatform.gcc.arch} or [ ]
    )
  );

  legacyConfMappings = {
    allowedUsers = "allowed-users";
    autoOptimiseStore = "auto-optimise-store";
    binaryCachePublicKeys = "trusted-public-keys";
    binaryCaches = "substituters";
    buildCores = "cores";
    maxJobs = "max-jobs";
    requireSignedBinaryCaches = "require-sigs";
    sandboxPaths = "extra-sandbox-paths";
    systemFeatures = "system-features";
    trustedBinaryCaches = "trusted-substituters";
    trustedUsers = "trusted-users";
    useSandbox = "sandbox";
  };

  semanticConfType =
    with types;
    let
      confAtom =
        nullOr (oneOf [
          bool
          int
          float
          str
          path
          package
        ])
        // {
          description = "Nix config atom (null, bool, int, float, str, path or package)";
        };
    in
    attrsOf (either confAtom (listOf confAtom));

  nixConf =
    (pkgs.formats.nixConf {
      inherit (cfg)
        package
        checkAllErrors
        checkConfig
        extraOptions
        ;

      inherit (nixPackage) version;
    }).generate
      "nix.conf"
      cfg.settings;

in
{
  imports = [
    (mkRenamedOptionModuleWith {
      from = [
        "nix"
        "useChroot"
      ];

      sinceRelease = 2003;

      to = [
        "nix"
        "useSandbox"
      ];
    })
    (mkRenamedOptionModuleWith {
      from = [
        "nix"
        "chrootDirs"
      ];

      sinceRelease = 2003;

      to = [
        "nix"
        "sandboxPaths"
      ];
    })
  ]
  ++ mapAttrsToList (
    oldConf: newConf:
    mkRenamedOptionModuleWith {
      from = [
        "nix"
        oldConf
      ];

      sinceRelease = 2205;

      to = [
        "nix"
        "settings"
        newConf
      ];
    }
  ) legacyConfMappings;

  options = {
    nix = {
      checkAllErrors = mkOption {
        default = true;

        description = ''
          If enabled, checks the nix.conf parsing for any kind of error. When disabled, checks only for unknown settings.
        '';

        type = types.bool;
      };

      checkConfig = mkOption {
        default = true;

        description = ''
          If enabled, checks that Nix can parse the generated nix.conf.
        '';

        type = types.bool;
      };

      extraOptions = mkOption {
        default = "";
        description = "Additional text appended to {file}`nix.conf`.";

        example = ''
          keep-outputs = true
          keep-derivations = true
        '';

        type = types.lines;
      };

      settings = mkOption {
        default = { };

        description = ''
          Configuration for Nix, see
          <https://nixos.org/manual/nix/stable/command-ref/conf-file.html> or
          {manpage}`nix.conf(5)` for available options.
          The value declared here will be translated directly to the key-value pairs Nix expects.

          You can use {command}`nix-instantiate --eval --strict '<nixpkgs/nixos>' -A config.nix.settings`
          to view the current value. By default it is empty.

          Nix configurations defined under {option}`nix.*` will be translated and applied to this
          option. In addition, configuration specified in {option}`nix.extraOptions` will be appended
          verbatim to the resulting config file.
        '';

        example = literalExpression ''
          {
            use-sandbox = true;
            show-trace = true;

            sandbox-paths = [ "/bin/sh=''${pkgs.busybox-sandbox-shell.out}/bin/busybox" ];
          }
        '';

        type = types.submodule {
          options = {
            allowed-users = mkOption {
              default = [ "*" ];

              description = ''
                A list of names of users (separated by whitespace) that are
                allowed to connect to the Nix daemon. As with
                {option}`nix.settings.trusted-users`, you can specify groups by
                prefixing them with `@`. Also, you can
                allow all users by specifying `*`. The
                default is `*`. Note that trusted users are
                always allowed to connect.
              '';

              example = [
                "@wheel"
                "@builders"
                "alice"
                "bob"
              ];

              type = types.listOf types.str;
            };

            auto-optimise-store = mkOption {
              default = false;

              description = ''
                If set to true, Nix automatically detects files in the store that have
                identical contents, and replaces them with hard links to a single copy.
                This saves disk space. If set to false (the default), you can still run
                nix-store --optimise to get rid of duplicate files.
              '';

              example = true;
              type = types.bool;
            };

            cores = mkOption {
              default = 0;

              description = ''
                This option defines the maximum number of concurrent tasks during
                one build. It affects, e.g., -j option for make.
                The special value 0 means that the builder should use all
                available CPU cores in the system. Some builds may become
                non-deterministic with this option; use with care! Packages will
                only be affected if enableParallelBuilding is set for them.
              '';

              example = 64;
              type = types.int;
            };

            extra-sandbox-paths = mkOption {
              default = [ ];

              description = ''
                Directories from the host filesystem to be included
                in the sandbox.
              '';

              example = [
                "/dev"
                "/proc"
              ];

              type = types.listOf types.str;
            };

            max-jobs = mkOption {
              default = "auto";

              description = ''
                This option defines the maximum number of jobs that Nix will try to
                build in parallel. The default is auto, which means it will use all
                available logical cores. It is recommend to set it to the total
                number of logical cores in your system (e.g., 16 for two CPUs with 4
                cores each and hyper-threading).
              '';

              example = 64;
              type = types.either types.int (types.enum [ "auto" ]);
            };

            require-sigs = mkOption {
              default = true;

              description = ''
                If enabled (the default), Nix will only download binaries from binary caches if
                they are cryptographically signed with any of the keys listed in
                {option}`nix.settings.trusted-public-keys`. If disabled, signatures are neither
                required nor checked, so it's strongly recommended that you use only
                trustworthy caches and https to prevent man-in-the-middle attacks.
              '';

              type = types.bool;
            };

            sandbox = mkOption {
              default = true;

              description = ''
                If set, Nix will perform builds in a sandboxed environment that it
                will set up automatically for each build. This prevents impurities
                in builds by disallowing access to dependencies outside of the Nix
                store by using network and mount namespaces in a chroot environment.

                This is enabled by default even though it has a possible performance
                impact due to the initial setup time of a sandbox for each build. It
                doesn't affect derivation hashes, so changing this option will not
                trigger a rebuild of packages.

                When set to "relaxed", this option permits derivations that set
                `__noChroot = true;` to run outside of the sandboxed environment.
                Exercise caution when using this mode of operation! It is intended to
                be a quick hack when building with packages that are not easily setup
                to be built reproducibly.
              '';

              type = types.either types.bool (types.enum [ "relaxed" ]);
            };

            substituters = mkOption {
              description = ''
                List of binary cache URLs used to obtain pre-built binaries
                of Nix packages.

                By default https://cache.nixos.org/ is added.
              '';

              type = types.listOf types.str;
            };

            system-features = mkOption {
              # We expose system-featuers here and in config below.
              # This allows users to access the default value via `options.nix.settings.system-features`
              default = defaultSystemFeatures;
              defaultText = literalExpression ''[ "nixos-test" "benchmark" "big-parallel" "kvm" "gccarch-<arch>" ]'';

              description = ''
                The set of features supported by the machine. Derivations
                can express dependencies on system features through the
                `requiredSystemFeatures` attribute.
              '';

              type = types.listOf types.str;
            };

            trusted-public-keys = mkOption {
              description = ''
                List of public keys used to sign binary caches. If
                {option}`nix.settings.trusted-public-keys` is enabled,
                then Nix will use a binary from a binary cache if and only
                if it is signed by *any* of the keys
                listed here. By default, only the key for
                `cache.nixos.org` is included.
              '';

              example = [ "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs=" ];
              type = types.listOf types.str;
            };

            trusted-substituters = mkOption {
              default = [ ];

              description = ''
                List of binary cache URLs that non-root users can use (in
                addition to those specified using
                {option}`nix.settings.substituters`) by passing
                `--option binary-caches` to Nix commands.
              '';

              example = [ "https://hydra.nixos.org/" ];
              type = types.listOf types.str;
            };

            trusted-users = mkOption {
              description = ''
                A list of names of users that have additional rights when
                connecting to the Nix daemon, such as the ability to specify
                additional binary caches, or to import unsigned NARs. You
                can also specify groups by prefixing them with
                `@`; for instance,
                `@wheel` means all users in the wheel
                group.
              '';

              example = [
                "root"
                "alice"
                "@wheel"
              ];

              type = types.listOf types.str;
            };
          };

          freeformType = semanticConfType;
        };
      };
    };
  };

  config = mkIf cfg.enable {
    environment.etc."nix/nix.conf".source = nixConf;

    nix.settings = {
      substituters = mkAfter [ "https://cache.nixos.org/" ];
      system-features = defaultSystemFeatures;
      trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
      trusted-users = [ "root" ];
    };
  };
}
