{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
}:

buildDotnetModule rec {
  pname = "torrentstream";
  version = "1.0.1.11";

  src = fetchFromGitHub {
    owner = "trueromanus";
    repo = "TorrentStream";
    rev = version;
    hash = "sha256-3lmQWx00Ulp0ZyQBEhFT+djHBi84foMlWGJEp/UOGek=";
  };

  patches = [
    ./0001-display-the-message-of-caught-exceptions.patch
  ];

  dotnet-runtime = dotnetCorePackages.aspnetcore_8_0;
  dotnet-sdk = dotnetCorePackages.sdk_8_0;

  dotnetFlags = [
    "-p:PublishAot=false" # untill https://github.com/NixOS/nixpkgs/issues/280923 is fixed
    "-p:PublishSingleFile=true"
  ];

  executables = [ "TorrentStream" ];
  nugetDeps = ./deps.json;
  projectFile = "TorrentStream.csproj";
  selfContainedBuild = true;
  sourceRoot = "${src.name}/src";

  meta = {
    description = "Simple web server for streaming torrent files in video players";
    homepage = "https://github.com/trueromanus/TorrentStream";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ _3JlOy-PYCCKUi ];
    platforms = lib.platforms.all;
    mainProgram = "TorrentStream";
  };
}
