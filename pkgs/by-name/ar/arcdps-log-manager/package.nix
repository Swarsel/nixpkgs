{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  copyDesktopItems,
  dotnetCorePackages,
  gtk3,
  icoutils,
  libnotify,
  makeDesktopItem,
  nix-update-script,
  wrapGAppsHook3,
}:
buildDotnetModule (finalAttrs: {
  pname = "arcdps-log-manager";
  version = "1.16";

  src = fetchFromGitHub {
    owner = "gw2scratch";
    repo = "evtc";
    tag = "manager-v${finalAttrs.version}";
    hash = "sha256-AiIWYb3hwkE20NdmAHlSt55QJ/d3NnQt3ZeX1COUG7k=";
  };

  nativeBuildInputs = [
    wrapGAppsHook3
    icoutils
    copyDesktopItems
  ];

  postInstall = ''
    mkdir -p $out/share/icons/hicolor/128x128/apps
    icotool -x $src/ArcdpsLogManager/Images/program_icon.ico
    cp program_icon_1_128x128x32.png $out/share/icons/hicolor/128x128/apps/arcdps-log-manager.png
  '';

  desktopItems = [
    (makeDesktopItem {
      desktopName = "arcdps Log Manager";
      exec = "GW2Scratch.ArcdpsLogManager.Gtk";
      genericName = "arcdps Log Manager";
      icon = "arcdps-log-manager";
      name = "arcdps Log Manager";
    })
  ];

  dotnet-runtime = dotnetCorePackages.runtime_8_0;
  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  nugetDeps = ./deps.json;
  projectFile = "ArcdpsLogManager.Gtk/ArcdpsLogManager.Gtk.csproj";

  runtimeDeps = [
    gtk3
    libnotify
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version-regex=manager-v(.*)" ];
  };

  meta = {
    description = "Manager for Guild Wars 2 log files";

    longDescription = ''
      Manager for all your recorded logs. Filter logs, upload them with one click, find interesting statistics.
    '';

    homepage = "https://gw2scratch.com/tools/manager";
    changelog = "https://github.com/gw2scratch/evtc/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.Blu3 ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "GW2Scratch.ArcdpsLogManager.Gtk";
  };
})
