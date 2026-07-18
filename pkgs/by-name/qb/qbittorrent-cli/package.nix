{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  nix-update-script,
  versionCheckHook,
}:
let
  version = "1.8.24285.1";
in
buildDotnetModule {
  inherit version;
  pname = "qbittorrent-cli";

  src = fetchFromGitHub {
    owner = "fedarovich";
    repo = "qbittorrent-cli";
    tag = "v${version}";
    hash = "sha256-ZGK8nicaXlDIShACeF4QS0BOCZCN0T4JFtHuuFoXhBw=";
  };

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  dotnetBuildFlags = [
    "-f"
    "net6"
  ];

  dotnetInstallFlags = [
    "-f"
    "net6"
  ];

  executables = [ "qbt" ];
  nugetDeps = ./deps.json;
  projectFile = "src/QBittorrent.CommandLineInterface/QBittorrent.CommandLineInterface.csproj";
  selfContainedBuild = true;
  versionCheckProgram = "${placeholder "out"}/bin/qbt";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Command line interface for qBittorrent";
    homepage = "https://github.com/fedarovich/qbittorrent-cli";
    changelog = "https://github.com/fedarovich/qbittorrent-cli/releases/tag/v${version}";

    license = with lib.licenses; [
      mit
    ];

    maintainers = with lib.maintainers; [
      pta2002
    ];

    platforms = lib.platforms.unix;

    badPlatforms = [
      # error NETSDK1084: There is no application host available for the specified RuntimeIdentifier 'osx-arm64'
      "aarch64-darwin"
    ];

    mainProgram = "qbt";
  };
}
