{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  copyDesktopItems,
  dotnetCorePackages,
  makeDesktopItem,
}:
buildDotnetModule rec {
  pname = "melonloader-installer";
  version = "4.3.0";

  src = fetchFromGitHub {
    owner = "LavaGang";
    repo = "MelonLoader.Installer";
    tag = version;
    hash = "sha256-6tSbLgr44xBoJsNOGUq62KBirIU6sNCy24fwKROZRPE=";
  };

  patches = [
    ./disable-auto-updates.patch
  ];

  strictDeps = true;
  nativeBuildInputs = [ copyDesktopItems ];

  postInstall = ''
    install -Dm644 Resources/ML_Icon.png $out/share/icons/MelonLoader.Installer.Linux.png
  '';

  __structuredAttrs = true;

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Game"
        "Utility"
      ];

      comment = meta.description;
      desktopName = "MelonLoader Installer";
      exec = meta.mainProgram;
      icon = meta.mainProgram;
      name = pname;
    })
  ];

  dotnet-runtime = dotnetCorePackages.runtime_9_0;
  dotnet-sdk = dotnetCorePackages.sdk_9_0;
  nugetDeps = ./deps.json;
  projectFile = "MelonLoader.Installer/MelonLoader.Installer.csproj";
  selfContainedBuild = true;
  passthru.updateScript = ./update.sh;

  meta = {
    description = "Automated installer for MelonLoader, the universal mod-loader for games built in the Unity Engine";
    homepage = "https://melonwiki.xyz";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ WillemToorenburgh ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "MelonLoader.Installer.Linux";
  };
}
