{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
  versionCheckHook,
}:

buildDotnetModule (finalAttrs: {
  pname = "officecli";
  version = "1.0.129";

  src = fetchFromGitHub {
    owner = "iOfficeAI";
    repo = "OfficeCLI";
    tag = "v${finalAttrs.version}";
    hash = "sha256-r7hGIK6tp/Z5Nt2SASkvuXsjjq3apP7CuhHNi6FAc0k=";
  };

  strictDeps = true;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;
  dotnet-runtime = dotnetCorePackages.runtime_10_0;
  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  executables = [ "officecli" ];

  makeWrapperArgs = [
    "--set"
    "OFFICECLI_SKIP_UPDATE"
    "1"
  ];

  nugetDeps = ./deps.json;
  projectFile = "src/officecli/officecli.csproj";
  selfContainedBuild = true;

  meta = {
    description = "Command-line tool for creating, reading and editing Office documents";
    homepage = "https://github.com/iOfficeAI/OfficeCLI";
    changelog = "https://github.com/iOfficeAI/OfficeCLI/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;

    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode
    ];

    maintainers = with lib.maintainers; [ qrzbing ];
    platforms = finalAttrs.dotnet-sdk.meta.platforms;
    mainProgram = "officecli";
  };
})
