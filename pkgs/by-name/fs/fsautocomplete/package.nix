{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
  nix-update-script,
  testers,
}:

buildDotnetModule (finalAttrs: {
  pname = "fsautocomplete";
  version = "0.83.0";

  src = fetchFromGitHub {
    owner = "ionide";
    repo = "FsAutoComplete";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1WK6vb/UfqnF5KlwrjmGTPeAnEgwPswcYweeotB6j00=";
  };

  postPatch = ''
    rm global.json

    substituteInPlace src/FsAutoComplete/FsAutoComplete.fsproj \
      --replace-fail TargetFrameworks TargetFramework
  '';

  dotnet-runtime = dotnetCorePackages.sdk_8_0;
  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  executables = [ "fsautocomplete" ];
  nugetDeps = ./deps.json;
  projectFile = "src/FsAutoComplete/FsAutoComplete.fsproj";
  useDotnetFromEnv = true;

  passthru = {
    tests.version = testers.testVersion { package = finalAttrs.finalPackage; };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Backend service for rich editing or intellisense features for editors";
    homepage = "https://github.com/ionide/FsAutoComplete";
    changelog = "https://github.com/ionide/FsAutoComplete/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      gbtb
      mdarocha
    ];

    platforms = lib.platforms.unix;
    mainProgram = "fsautocomplete";
  };
})
