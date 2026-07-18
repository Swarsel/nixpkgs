{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  curl,
  dotnetCorePackages,
  jq,
  unzip,
}:

buildDotnetModule (finalAttrs: {
  pname = "steam-lancache-prefill";
  version = "3.5.1";

  src = fetchFromGitHub {
    owner = "tpill90";
    repo = "steam-lancache-prefill";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BDJB4kubcA9Uu84CubZ0uyKYwYWQYq+pBJa0t0q481Y=";
    fetchSubmodules = true;
  };

  patches = [ ./current-dir-config.patch ];

  nativeBuildInputs = [
    curl
    jq
    unzip
  ];

  postInstall = ''
    rm -rf $out/lib/steam-lancache-prefill/update.sh
  '';

  dotnet-runtime = dotnetCorePackages.aspnetcore_8_0;
  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  executables = [ "SteamPrefill" ];
  nugetDeps = ./deps.json;
  projectFile = "SteamPrefill/SteamPrefill.csproj";

  meta = {
    description = "Automatically fills a Lancache with games from Steam";
    homepage = "https://github.com/tpill90/steam-lancache-prefill";
    changelog = "https://github.com/tpill90/steam-lancache-prefill/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ rhoriguchi ];
    platforms = lib.platforms.all;
    mainProgram = "SteamPrefill";
  };
})
