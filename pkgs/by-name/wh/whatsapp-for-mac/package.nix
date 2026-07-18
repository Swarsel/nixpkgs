{
  lib,
  common-updater-scripts,
  curl,
  fetchzip,
  stdenvNoCC,
  writeShellApplication,
  xmlstarlet,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "whatsapp-for-mac";
  version = "2.26.19.17";

  src = fetchzip {
    url = "https://web.whatsapp.com/desktop/mac_native/release/?version=${finalAttrs.version}&extension=zip&configuration=Release&branch=master";
    hash = "sha256-jR8Hi4IWSfPvCthe/zH6mACQYQsGLcBmj2m8vwXX8Do=";
    extension = "zip";
    name = "WhatsApp.app";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications"
    cp -r *.app "$out/Applications"

    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;
  sourceRoot = ".";

  passthru.updateScript = lib.getExe (writeShellApplication {
    name = "whatsapp-update-script";

    runtimeInputs = [
      curl
      xmlstarlet
      common-updater-scripts
    ];

    text = ''
      url=$(curl --silent "https://web.whatsapp.com/desktop/mac_native/updates/?branch=master&configuration=Release")
      version=$(echo "$url" | xmlstarlet sel -t -v "substring-before(substring-after(//enclosure/@url, 'version='), '&')")
      update-source-version whatsapp-for-mac "$version" --file=./pkgs/by-name/wh/whatsapp-for-mac/package.nix
    '';
  });

  meta = {
    description = "Native desktop client for WhatsApp";
    homepage = "https://www.whatsapp.com/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ iivusly ];
    platforms = lib.platforms.darwin;
  };
})
