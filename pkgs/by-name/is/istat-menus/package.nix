{
  lib,
  fetchurl,
  common-updater-scripts,
  curl,
  stdenvNoCC,
  unzip,
  writeShellApplication,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "istat-menus";
  version = "7.20";

  src = fetchurl {
    url = "https://cdn.istatmenus.app/files/istatmenus${lib.versions.major finalAttrs.version}/versions/iStatMenus${finalAttrs.version}.zip";
    hash = "sha256-oJApYp7ejtcMrm7CyeohV/euXYkJJ0yCRBW2i5AgcEE=";
  };

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications"
    cp -r *.app "$out/Applications"

    runHook postInstall
  '';

  sourceRoot = ".";

  passthru.updateScript = lib.getExe (writeShellApplication {
    name = "istatmenus-update-script";

    runtimeInputs = [
      curl
      common-updater-scripts
    ];

    text = ''
      redirect_url="$(curl -s -L -f "https://download.bjango.com/istatmenus${lib.versions.major finalAttrs.version}/" -o /dev/null -w '%{url_effective}')"
      version="''${redirect_url##*/}"; version="''${version#iStatMenus}"; version="''${version%.zip}"
      update-source-version istat-menus "$version"
    '';
  });

  meta = {
    description = "Set of nine separate and highly configurable menu items that let you know exactly what's going on inside your Mac";
    homepage = "https://bjango.com/mac/istatmenus/";
    changelog = "https://bjango.com/mac/istatmenus/versionhistory/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ _4evy ];
    platforms = lib.platforms.darwin;
  };
})
