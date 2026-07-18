{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  alsa-lib,
  config,
  coreutils,
  file,
  freetype,
  gnugrep,
  libpulseaudio,
  libtool,
  libuuid,
  libx11,
  libxrandr,
  openssl,
  pango,
  pkg-config,
}:
let
  buildVM =
    {
      configureFlags,
      configureFlagsArray,
      # VM-specific information, manually extracted from building/<platformDir>/<vmName>/build/mvm
      platformDir,
      scriptName,
      vmName,
    }:
    let
      src = fetchFromGitHub {
        owner = "OpenSmalltalk";
        repo = "opensmalltalk-vm";
        tag = "202206021410";
        hash = "sha256-QqElPiJuqD5svFjWrLz1zL0Tf+pHxQ2fPvkVRn2lyBI=";
      };
    in
    stdenv.mkDerivation {
      inherit src;

      pname =
        let
          vmNameNoDots = builtins.replaceStrings [ "." ] [ "-" ] vmName;
        in
        "opensmalltalk-vm-${platformDir}-${vmNameNoDots}";

      version = src.rev;

      postPatch = ''
        vmVersionFiles=$(sed -n 's/^versionfiles="\(.*\)"/\1/p' ./scripts/updateSCCSVersions)
        for vmVersionFile in $vmVersionFiles; do
          substituteInPlace "$vmVersionFile" \
            --replace "\$Date\$" "\$Date: Thu Jan 1 00:00:00 1970 +0000 \$" \
            --replace "\$URL\$" "\$URL: ${src.url} \$" \
            --replace "\$Rev\$" "\$Rev: ${src.rev} \$" \
            --replace "\$CommitHash\$" "\$CommitHash: 000000000000 \$"
        done
        patchShebangs --build ./building/${platformDir} scripts
        substituteInPlace ./platforms/unix/config/mkmf \
          --replace "/bin/rm" "rm"
        substituteInPlace ./platforms/unix/config/configure \
          --replace "/usr/bin/file" "file" \
          --replace "/usr/bin/pkg-config" "pkg-config"
      '';

      nativeBuildInputs = [
        file
        pkg-config
      ];

      buildInputs = [
        alsa-lib
        freetype
        libpulseaudio
        libtool
        libuuid
        openssl
        pango
        libx11
        libxrandr
      ];

      configureFlags = [ "--with-scriptname=${scriptName}" ] ++ configureFlags;
      buildFlags = [ "all" ];

      preConfigure = ''
        cd building/${platformDir}/${vmName}/build
        # Exits with non-zero code if the check fails, counterintuitively
        ../../../../scripts/checkSCCSversion && exit 1
        cp ../plugins.int ../plugins.ext .
        configureFlagsArray=${configureFlagsArray}
      '';

      postInstall = ''
        rm "$out/squeak"
        cd "$out/bin"
        BIN="$(find ../lib -type f -name squeak)"
        for f in $(find . -type f); do
          rm "$f"
          ln -s "$BIN" "$f"
        done
      '';

      configureScript = "../../../../platforms/unix/config/configure";
      enableParallelBuilding = true;

      meta = {
        description = "Cross-platform virtual machine for Squeak, Pharo, Cuis, and Newspeak";
        homepage = "https://opensmalltalk.org/";
        license = with lib.licenses; [ mit ];
        maintainers = with lib.maintainers; [ jakewaksbaum ];
        platforms = [ stdenv.targetPlatform.system ];
        mainProgram = scriptName;
      };
    };

  vmsByPlatform = {
    "aarch64-linux" = {
      "squeak-cog-spur" = buildVM {
        configureFlags = [
          "--with-vmversion=5.0"
          "--with-src=src/spur64.cog"
          "--without-npsqueak"
          "--enable-fast-bitblt"
        ];

        configureFlagsArray = ''
          (
            CFLAGS="-DNDEBUG -DDEBUGVM=0 -DMUSL -D_GNU_SOURCE -DUSEEVDEV -DCOGMTVM=0 -DDUAL_MAPPED_CODE_ZONE=1"
            LIBS="-lrt"
          )
        '';

        platformDir = "linux64ARMv8";
        scriptName = "squeak";
        vmName = "squeak.cog.spur";
      };

      "squeak-stack-spur" = buildVM {
        configureFlags = [
          "--with-vmversion=5.0"
          "--with-src=src/spur64.stack"
          "--disable-cogit"
          "--without-npsqueak"
        ];

        configureFlagsArray = ''
          (
            CFLAGS="-DNDEBUG -DDEBUGVM=0 -DMUSL -D_GNU_SOURCE -DUSEEVDEV -D__ARM_ARCH_ISA_A64 -DARM64 -D__arm__ -D__arm64__ -D__aarch64__"
          )
        '';

        platformDir = "linux64ARMv8";
        scriptName = "squeak";
        vmName = "squeak.stack.spur";
      };
    };

    "x86_64-linux" = {
      "newspeak-cog-spur" = buildVM {
        configureFlags = [
          "--with-vmversion=5.0"
          "--with-src=src/spur64.cog.newspeak"
          "--without-vm-display-fbdev"
          "--without-npsqueak"
        ];

        configureFlagsArray = ''
          (
            CFLAGS="-DNDEBUG -DDEBUGVM=0"
          )
        '';

        platformDir = "linux64x64";
        scriptName = "newspeak";
        vmName = "newspeak.cog.spur";
      };

      "squeak-cog-spur" = buildVM {
        configureFlags = [
          "--with-vmversion=5.0"
          "--with-src=src/spur64.cog"
          "--without-npsqueak"
        ];

        configureFlagsArray = ''
          (
            CFLAGS="-DNDEBUG -DDEBUGVM=0 -DCOGMTVM=0"
          )
        '';

        platformDir = "linux64x64";
        scriptName = "squeak";
        vmName = "squeak.cog.spur";
      };
    };
  };

  platform = stdenv.targetPlatform.system;
in
if (!config.allowAliases && !(vmsByPlatform ? platform)) then
  # Don't throw without aliases to not break CI.
  null
else
  vmsByPlatform.${platform} or (throw (
    "Unsupported platform ${platform}: only the following platforms are supported: "
    + toString (builtins.attrNames vmsByPlatform)
  ))
