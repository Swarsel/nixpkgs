{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
}:

buildDotnetModule (finalAttrs: {
  pname = "rockstarlang";
  version = "2.0.31";

  src = fetchFromGitHub {
    owner = "RockstarLang";
    repo = "rockstar";
    rev = "v${finalAttrs.version}";
    hash = "sha256-243rN8hVaIfkEkkbgHZr2HKmqvG9KBVhvvoYJwoWgQs=";
  };

  doInstallCheck = true;

  installCheckPhase = ''
    {
      echo 'Shout "it seems to work"'
      echo 'exit'
    } | $out/bin/rockstar | grep '« "it seems to work"'
  '';

  dotnet-sdk = dotnetCorePackages.dotnet_9.sdk;
  executables = "rockstar";
  nugetDeps = ./deps.json;
  projectFile = "Starship/Rockstar/Rockstar.csproj";
  selfContainedBuild = true;

  meta = {
    description = "Esoteric programming language whose syntax is inspired by the lyrics to 80s hard rock and heavy metal songs";
    homepage = "https://codewithrockstar.com";
    license = lib.licenses.agpl3Only;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    maintainers = [ lib.maintainers.pinage404 ];
    mainProgram = "rockstar";
  };
})
