{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  azure-static-sites-client,
  curl,
  icu70,
  libkrb5,
  lttng-ust,
  openssl,
  zlib,
  # "latest", "stable" or "backup"
  versionFlavor ? "stable",
}:
let
  versions = lib.importJSON ./versions.json;
  flavor = lib.head (lib.filter (x: x.version == versionFlavor) versions);
  fetchBinary =
    runtimeId:
    fetchurl {
      sha256 = flavor.files.${runtimeId}.sha;
      url = flavor.files.${runtimeId}.url;
    };
  sources = {
    "x86_64-linux" = fetchBinary "linux-x64";
  };
in
stdenv.mkDerivation {
  pname = "StaticSitesClient-${versionFlavor}";
  version = flavor.buildId;

  src =
    sources.${stdenv.hostPlatform.system}
      or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    curl
    icu70
    libkrb5
    lttng-ust
    openssl
    (lib.getLib stdenv.cc.cc)
    zlib
  ];

  installPhase = ''
    runHook preInstall

    install -m755 "$src" -D "$out/bin/StaticSitesClient"

    for icu_lib in 'icui18n' 'icuuc' 'icudata'; do
      patchelf --add-needed "lib''${icu_lib}.so.${lib.head (lib.splitVersion (lib.getVersion icu70.name))}" "$out/bin/StaticSitesClient"
    done

    patchelf --add-needed 'libgssapi_krb5.so' \
             --add-needed 'liblttng-ust.so'   \
             --add-needed 'libssl.so.3'     \
             "$out/bin/StaticSitesClient"

    runHook postInstall
  '';

  # Just make sure the binary executes successfully
  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck

    $out/bin/StaticSitesClient version

    runHook postInstallCheck
  '';

  dontBuild = true;
  # Stripping kills the binary
  dontStrip = true;
  dontUnpack = true;

  passthru = {
    # Create tests for all flavors
    tests = lib.genAttrs (map (x: x.version) versions) (
      versionFlavor: azure-static-sites-client.override { inherit versionFlavor; }
    );

    updateScript = ./update.sh;
  };

  meta = {
    description = "Azure static sites client";
    homepage = "https://github.com/Azure/static-web-apps-cli";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ veehaitch ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "StaticSitesClient";
  };
}
