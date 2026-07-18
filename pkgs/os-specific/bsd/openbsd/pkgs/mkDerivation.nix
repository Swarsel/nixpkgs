{
  lib,
  stdenv,
  bsdSetupHook,
  install,
  lorder,
  makeMinimal,
  openbsdSetupHook,
  rsync,
  runCommand,
  source,
  stdenvLibcMinimal,
  stdenvNoCC,
  stdenvNoLibc,
  tsort,
}:

lib.makeOverridable (
  attrs:
  let
    stdenv' =
      if attrs.noCC or false then
        stdenvNoCC
      else if attrs.noLibc or false then
        stdenvNoLibc
      else if attrs.libcMinimal or false then
        stdenvLibcMinimal
      else
        stdenv;

    machineMap = {
      aarch64 = "arm64";
      armv7l = "armv7";
      i486 = "i386";
      i586 = "i386";
      i686 = "i386";
      x86_64 = "amd64";
    };

    archMap = {
      aarch64 = "aarch64";
      armv7l = "arm";
      i486 = "i386";
      i586 = "i386";
      i686 = "i386";
      x86_64 = "amd64";
    };

  in
  stdenv'.mkDerivation (
    rec {
      pname = "${attrs.pname or (baseNameOf attrs.path)}-openbsd";
      version = "0";

      src = runCommand "${pname}-filtered-src" { nativeBuildInputs = [ rsync ]; } ''
        for p in ${lib.concatStringsSep " " ([ attrs.path ] ++ attrs.extraPaths or [ ])}; do
          set -x
          path="$out/$p"
          mkdir -p "$(dirname "$path")"
          src_path="${source}/$p"
          if [[ -d "$src_path" ]]; then src_path+=/; fi
          rsync --chmod="+w" -r "$src_path" "$path"
          set +x
        done
      '';

      strictDeps = true;

      nativeBuildInputs = [
        bsdSetupHook
        openbsdSetupHook
        makeMinimal
        install
        tsort
        lorder
      ]
      ++ (attrs.extraNativeBuildInputs or [ ]);

      COMPONENT_PATH = attrs.path or null;
      HOST_SH = stdenv'.shell;
      MACHINE = machineMap.${stdenv'.hostPlatform.parsed.cpu.name};
      MACHINE_ARCH = archMap.${stdenv'.hostPlatform.parsed.cpu.name};
      MACHINE_CPU = MACHINE_ARCH;
      TARGET_MACHINE_ARCH = archMap.${stdenv'.targetPlatform.parsed.cpu.name};
      TARGET_MACHINE_CPU = TARGET_MACHINE_ARCH;
      extraPaths = [ ];

      meta = {
        license = lib.licenses.bsd2;
        maintainers = with lib.maintainers; [ ericson2314 ];
        platforms = lib.platforms.openbsd;
      };
    }
    // lib.optionalAttrs stdenv'.hasCC {
      # TODO should CC wrapper set this?
      CPP = "${stdenv'.cc.targetPrefix}cpp";
    }
    // lib.optionalAttrs (attrs.headersOnly or false) {
      installPhase = "includesPhase";
      dontBuild = true;
    }
    // lib.optionalAttrs stdenv'.hostPlatform.isStatic { NOLIBSHARED = true; }
    // (removeAttrs attrs [ "extraNativeBuildInputs" ])
  )
)
