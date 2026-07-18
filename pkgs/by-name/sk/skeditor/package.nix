{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  copyDesktopItems,
  dotnetCorePackages,
  iconConvTools,
  makeDesktopItem,
}:
buildDotnetModule rec {
  pname = "skeditor";
  version = "2.9.3";

  src = fetchFromGitHub {
    owner = "skeditorteam";
    repo = "skeditor";
    rev = "v${version}";
    hash = "sha256-KC9s9FE/6te8JnLcSBZNQ05DpKFG7jT6eHDS6OWsOBU=";
  };

  nativeBuildInputs = [
    iconConvTools
    copyDesktopItems
  ];

  postInstall = ''
    icoFileToHiColorTheme SkEditor/Assets/SkEditor.ico skeditor $out
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Utility"
        "TextEditor"
        "Development"
        "IDE"
      ];

      desktopName = "SkEditor";
      exec = meta.mainProgram;
      genericName = "Skript Editor";
      icon = "SkEditor";

      keywords = [
        "skeditor"
        "SkEditor"
      ];

      name = pname;
      startupWMClass = "SkEditor";
    })
  ];

  dotnet-runtime = dotnetCorePackages.runtime_8_0;
  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  executables = [ "SkEditor" ];
  nugetDeps = ./nuget-deps.json;
  projectFile = "SkEditor/SkEditor.csproj";
  passthru.updateScript = ./update.sh;

  meta = {
    description = "App for editing Skript files";
    homepage = "https://github.com/SkEditorTeam/SkEditor";
    changelog = "https://github.com/SkEditorTeam/SkEditor/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ eveeifyeve ];
    mainProgram = "SkEditor";
  };
}
