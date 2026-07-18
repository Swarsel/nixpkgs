{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnet-aspnetcore_8,
  dotnet-sdk_8,
  mediainfo,
  nix-update-script,
  nixosTests,
  rhash,
}:

buildDotnetModule (finalAttrs: {
  pname = "shoko";
  version = "5.3.3";

  src = fetchFromGitHub {
    owner = "ShokoAnime";
    repo = "ShokoServer";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PJtjG4YJBgUrjBt/S2uWyKrCj1pW4N9wrLqoh2gHKcg=";
    fetchSubmodules = true;
  };

  dotnet-runtime = dotnet-aspnetcore_8;
  dotnet-sdk = dotnet-sdk_8;
  dotnetBuildFlags = "/p:InformationalVersion=\"channel=stable\"";
  executables = [ "Shoko.CLI" ];

  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    "${mediainfo}/bin"
  ];

  nugetDeps = ./deps.json;
  projectFile = "Shoko.CLI/Shoko.CLI.csproj";
  runtimeDeps = [ rhash ];

  passthru = {
    tests = { inherit (nixosTests) shoko; };

    updateScript = nix-update-script {
      extraArgs = [
        "--version-regex"
        ''v([0-9]+\.[0-9]+\.[0-9]+).*''
      ];
    };
  };

  meta = {
    inherit (dotnet-sdk_8.meta) platforms;
    description = "Backend for the Shoko anime management system";
    homepage = "https://github.com/ShokoAnime/ShokoServer";
    changelog = "https://github.com/ShokoAnime/ShokoServer/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nanoyaki ];
    mainProgram = "Shoko.CLI";
  };
})
