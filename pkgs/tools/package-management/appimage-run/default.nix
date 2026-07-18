{
  lib,
  appimageTools,
  buildFHSEnv,
  makeDesktopItem,
  appimage-run-tests ? null,
  extraPkgs ? pkgs: [ ],
}:

let
  name = "appimage-run";

  fhsArgs = appimageTools.defaultFhsEnvArgs;

  desktopItem = makeDesktopItem {
    inherit name;

    categories = [
      "PackageManager"
      "Utility"
    ];

    desktopName = name;
    exec = name;
    genericName = "AppImage runner";

    mimeTypes = [
      "application/vnd.appimage"
      "application/x-iso9660-appimage"
    ];

    noDisplay = true;
  };
in
buildFHSEnv (
  lib.recursiveUpdate fhsArgs {
    inherit name;

    extraInstallCommands = ''
      cp --recursive "${desktopItem}/share" "$out/"
    '';

    runScript = "appimage-exec.sh";
    targetPkgs = pkgs: [ appimageTools.appimage-exec ] ++ fhsArgs.targetPkgs pkgs ++ extraPkgs pkgs;
    passthru.tests.appimage-run = appimage-run-tests;
    meta.mainProgram = "appimage-run";
  }
)
