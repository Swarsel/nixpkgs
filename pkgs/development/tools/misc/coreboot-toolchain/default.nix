{
  lib,
  stdenv,
  callPackage,
}:
let
  common =
    arch:
    callPackage (
      {
        lib,
        bison,
        callPackage,
        curl,
        fetchgit,
        flex,
        gcc14,
        getopt,
        git,
        gnat14,
        perl,
        stdenvNoCC,
        zlib,
        withAda ? true,
      }:

      stdenvNoCC.mkDerivation (finalAttrs: {
        pname = "coreboot-toolchain-${arch}";
        version = "26.06";

        src = fetchgit {
          url = "https://review.coreboot.org/coreboot";
          rev = finalAttrs.version;
          hash = "sha256-MESai+UGo/Ref5t1VcgCrgQk+2ZeZW4Vh0xk3Z5v8ZE=";
          fetchSubmodules = false;
          leaveDotGit = true;

          postFetch = ''
            PATH=${lib.makeBinPath [ getopt ]}:$PATH ${stdenv.shell} $out/util/crossgcc/buildgcc -W > $out/.crossgcc_version
            rm -rf $out/.git
          '';
        };

        postPatch = ''
          patchShebangs util/crossgcc/buildgcc

          mkdir -p util/crossgcc/tarballs

          ${lib.concatMapStringsSep "\n" (file: "ln -s ${file.archive} util/crossgcc/tarballs/${file.name}") (
            callPackage finalAttrs.archives { }
          )}

          patchShebangs util/genbuild_h/genbuild_h.sh
        '';

        nativeBuildInputs = [
          bison
          curl
          git
          perl
        ];

        buildInputs = [
          flex
          zlib
          (if withAda then gnat14 else gcc14)
        ];

        buildPhase = ''
          export CROSSGCC_VERSION=$(cat .crossgcc_version)
          make crossgcc-${arch} CPUS=$NIX_BUILD_CORES DEST=$out
        '';

        archives = ./stable.nix;
        dontConfigure = true;
        dontInstall = true;
        enableParallelBuilding = true;

        meta = {
          description = "Coreboot toolchain for ${arch} targets";
          homepage = "https://www.coreboot.org";

          license = with lib.licenses; [
            bsd2
            bsd3
            gpl2
            lgpl2Plus
            gpl3Plus
          ];

          maintainers = with lib.maintainers; [
            felixsinger
            jmbaur
          ];

          platforms = lib.platforms.linux;
        };
      })
    );
in

lib.listToAttrs (
  map (arch: lib.nameValuePair arch (common arch { })) [
    "i386"
    "x64"
    "arm"
    "aarch64"
    "riscv"
    "ppc64"
  ]
)
