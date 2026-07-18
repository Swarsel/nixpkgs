{
  lib,
  fetchurl,
  common-updater-scripts,
  curl,
  gnugrep,
  stdenvNoCC,
  writeShellApplication,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "tideways-daemon";
  version = "1.18.0";

  src =
    finalAttrs.passthru.sources.${stdenvNoCC.hostPlatform.system}
      or (throw "Unsupported platform for tideways-cli: ${stdenvNoCC.hostPlatform.system}");

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp tideways-daemon $out/bin/tideways-daemon
    chmod +x $out/bin/tideways-daemon
    runHook postInstall
  '';

  passthru = {
    sources = {
      "aarch64-darwin" = fetchurl {
        hash = "sha256-RcNG7jPt+bYiP4hzV6vaxVgSstDM2oWjOmo9TmpKcWM=";
        url = "https://tideways.s3.amazonaws.com/daemon/${finalAttrs.version}/tideways-daemon_macos_arm64-${finalAttrs.version}.tar.gz";
      };

      "aarch64-linux" = fetchurl {
        hash = "sha256-WxaJx/vkg139zm0xOzT+9FZRAk4v/YJcVHTXwDVcALE=";
        url = "https://tideways.s3.amazonaws.com/daemon/${finalAttrs.version}/tideways-daemon_linux_aarch64-${finalAttrs.version}.tar.gz";
      };

      "x86_64-linux" = fetchurl {
        hash = "sha256-sm5xITxGSbcWiI4hhxkHKFleTQBeZZBTH823KQz3M5U=";
        url = "https://tideways.s3.amazonaws.com/daemon/${finalAttrs.version}/tideways-daemon_linux_amd64-${finalAttrs.version}.tar.gz";
      };
    };

    updateScript = "${
      writeShellApplication {
        name = "update-tideways-daemon";

        runtimeInputs = [
          curl
          gnugrep
          common-updater-scripts
        ];

        text = ''
          NEW_VERSION=$(curl --fail -L -s https://tideways.com/profiler/downloads | grep -E 'https://tideways.s3.amazonaws.com/daemon/([0-9]+\.[0-9]+\.[0-9]+)/tideways-daemon_linux_amd64-\1.tar.gz' | grep -oP 'daemon/\K[0-9]+\.[0-9]+\.[0-9]+')

          if [[ "${finalAttrs.version}" = "$NEW_VERSION" ]]; then
              echo "The new version same as the old version."
              exit 0
          fi

          for platform in ${lib.escapeShellArgs finalAttrs.meta.platforms}; do
            update-source-version "tideways-daemon" "$NEW_VERSION" --ignore-same-version --source-key="sources.$platform"
          done
        '';
      }
    }/bin/update-tideways-daemon";
  };

  meta = {
    description = "Tideways Daemon";
    homepage = "https://tideways.com/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ shyim ];
    platforms = lib.attrNames finalAttrs.passthru.sources;
    mainProgram = "tideways-daemon";
  };
})
