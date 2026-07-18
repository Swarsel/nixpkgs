{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  copyDesktopItems,
  electron,
  makeDesktopItem,
  unstableGitUpdater,
  writeScriptBin,
  electronAppName ? "Antimatter Dimensions",
}:

let
  # build doesn't provide app.js, only index.html as entry point.
  # app.js is used to change the directory where data is stored
  # instead of default Electron. This workaround will be removed
  # when this file will be available in upstream repository.
  dummyElectronApp = ./app.js;
in
buildNpmPackage rec {
  pname = "antimatter-dimensions";
  version = "0-unstable-2025-11-20";

  src = fetchFromGitHub {
    owner = "IvarK";
    repo = "AntimatterDimensionsSourceCode";
    rev = "8ae221fcb07db667b3d04114c2b977175966611d";
    hash = "sha256-IseAfEz+nSzY2XD15HbJWeLmYFMvAYO33bPItXJCy58=";
  };

  nativeBuildInputs = [
    copyDesktopItems
    # build script calls git to get git hash, message and author
    # since fetchFromGitHub doesn't provide this information
    # and in order to keep determinism (#8567), create a dummy git
    (writeScriptBin "git" ''
      echo "unknown"
    '')
  ];

  npmDepsHash = "sha256-aG+oysgitQvdFM0QyzJ3DBxsanBHYI+UPJPhj6bf00Q=";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/antimatter-dimensions
    cp -Tr dist $out/share/antimatter-dimensions
    mkdir -p $out/share/icons/hicolor/256x256/apps
    ln -rs $out/share/antimatter-dimensions/icon.png $out/share/icons/hicolor/256x256/apps/antimatter-dimensions.png
    cp ${dummyElectronApp} $out/share/antimatter-dimensions/app.js

    makeWrapper ${lib.getExe electron} $out/bin/antimatter-dimensions \
      --add-flags $out/share/antimatter-dimensions/app.js \
      --set ELECTRON_APP_NAME "${electronAppName}"

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Game" ];
      comment = meta.description;
      desktopName = electronAppName;
      exec = "antimatter-dimensions";
      icon = "antimatter-dimensions";
      name = "antimatter-dimensions";
      terminal = false;
    })
  ];

  npmBuildScript = "build:release";
  npmFlags = [ "--legacy-peer-deps" ];

  passthru.updateScript = unstableGitUpdater {
    hardcodeZeroVersion = true;
  };

  meta = {
    inherit (electron.meta) platforms;
    description = "Idle incremental game with multiple prestige layers";
    homepage = "https://github.com/IvarK/AntimatterDimensionsSourceCode";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ amozeo ];
    mainProgram = "antimatter-dimensions";
  };
}
