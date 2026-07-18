{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
  go,
}:
let
  version = "4.8.0";
  templatesVersion = "3.1.1648";

  src = fetchFromGitHub {
    owner = "Azure";
    repo = "azure-functions-core-tools";
    tag = version;
    hash = "sha256-OY2FPzST1ejU+OPccv7Qvd8cM3gtiiL2CQNj2APDIx0=";
  };

  templates = fetchurl {
    hash = "sha256-YYKBwd69TIHQKF1r8BzlzIyDLJBcCqtAbK3FhNvA+5s=";
    url = "https://cdn.functions.azure.com/public/TemplatesApi/${templatesVersion}.zip";
  };
in
buildDotnetModule {
  inherit src version;
  pname = "azure-functions-core-tools";

  postPatch = ''
    templates_path="./out/obj/Azure.Functions.Cli/templates-staging"
    mkdir -p "$templates_path"
    cp "${templates}" "$templates_path/templates.zip"

    substituteInPlace src/Cli/func/Common/CommandChecker.cs \
      --replace-fail "CheckExitCode(\"/bin/bash" "CheckExitCode(\"${stdenv.shell}"
  '';

  nativeBuildInputs = [ go ];

  dotnet-sdk = dotnetCorePackages.sdk_10_0 // {
    inherit
      (dotnetCorePackages.combinePackages [
        dotnetCorePackages.sdk_9_0
        dotnetCorePackages.sdk_8_0
      ])
      packages
      targetPackages
      ;
  };

  executables = [ "func" ];
  linkNuGetPackagesAndSources = true;
  nugetDeps = ./deps.json;
  projectFile = "src/Cli/func/Azure.Functions.Cli.csproj";
  useDotnetFromEnv = true;

  meta = {
    description = "Command line tools for Azure Functions";
    homepage = "https://github.com/Azure/azure-functions-core-tools";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      mdarocha
      detegr
    ];

    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
    ];

    mainProgram = "func";
  };
}
