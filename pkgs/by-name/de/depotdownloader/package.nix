{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
}:

buildDotnetModule rec {
  pname = "depotdownloader";
  version = "3.4.0";

  src = fetchFromGitHub {
    owner = "SteamRE";
    repo = "DepotDownloader";
    rev = "DepotDownloader_${version}";
    hash = "sha256-zduNWIQi+ItNSh9RfRfY0giIw/tMQIMRh9woUzQ5pJw=";
  };

  dotnet-runtime = dotnetCorePackages.runtime_9_0;
  dotnet-sdk = dotnetCorePackages.sdk_9_0;
  nugetDeps = ./deps.json;
  projectFile = "DepotDownloader.sln";
  passthru.updateScript = ./update.sh;

  meta = {
    description = "Steam depot downloader utilizing the SteamKit2 library";
    homepage = "https://github.com/SteamRE/DepotDownloader";
    changelog = "https://github.com/SteamRE/DepotDownloader/releases/tag/DepotDownloader_${version}";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.babbaj ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    mainProgram = "DepotDownloader";
  };
}
