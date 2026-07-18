{
  lib,
  stdenv,
  fetchurl,
  common-updater-scripts,
  curl,
  installShellFiles,
  jq,
  unzip,
  writeShellScript,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "speakeasy-cli";
  version = "1.789.0";

  src =
    finalAttrs.passthru.sources.${stdenv.hostPlatform.system}
      or (throw "Unsupported System: ${stdenv.hostPlatform.system}");

  nativeBuildInputs = [
    unzip
    installShellFiles
  ];

  installPhase = ''
    runHook preInstall
    install -Dm 755 ./speakeasy $out/bin/speakeasy
    runHook postInstall
  '';

  sourceRoot = ".";

  passthru = {
    sources = {
      "aarch64-darwin" = fetchurl {
        hash = "sha256-UC9YUPKeUoe1C9x5sK6mO7BXBNQTYkvyKi42L3q3/Eg=";
        url = "https://github.com/speakeasy-api/speakeasy/releases/download/v${finalAttrs.version}/speakeasy_darwin_arm64.zip";
      };

      "aarch64-linux" = fetchurl {
        hash = "sha256-V4e6tZWd1iqpOeVbgefIlHxWuWjRVqS3zSY62FJwOF8=";
        url = "https://github.com/speakeasy-api/speakeasy/releases/download/v${finalAttrs.version}/speakeasy_linux_arm64.zip";
      };

      "x86_64-linux" = fetchurl {
        hash = "sha256-8QEtlte0PtbCVZjvcBd16zJf3weVju5nsS+PrDCMMl8=";
        url = "https://github.com/speakeasy-api/speakeasy/releases/download/v${finalAttrs.version}/speakeasy_linux_amd64.zip";
      };
    };

    updateScript = writeShellScript "update-speakeasy" ''
      set -o errxt
      export PATH="${
        lib.makeBinPath [
          curl
          jq
          common-updater-scripts
        ]
      }"
      NEW_VERSION=$(curl --silent https://api.github.com/repos/speakeasy-api/speakeasy/releases/latest | jq --raw-output '.tag_name | ltrimstr("v")')
      if [[ "${finalAttrs.version}" = "$NEW_VERSION" ]]; then
        echo "The new version is the same as old"
        exit 0
      fi
      for platform in ${lib.escapeShellArgs (builtins.attrNames finalAttrs.passthru.sources)}; do
        update-source-version "speakeasy-cli" "$NEW_VERSION" --ignore-same-version --source-key="sources.$platform"
      done
    '';
  };

  meta = {
    description = "CLI tool for Speakeasy";
    homepage = "https://www.speakeasyapi.dev/";
    changelog = "https://github.com/speakeasy-api/speakeasy/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.elastic20;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      eveeifyeve
    ];

    platforms = builtins.attrNames finalAttrs.passthru.sources;
    mainProgram = "speakeasy";
  };
})
