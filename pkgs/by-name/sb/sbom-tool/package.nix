{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
  nix-update-script,
  versionCheckHook,
}:

buildDotnetModule rec {
  pname = "sbom-tool";
  version = "4.1.11";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "sbom-tool";
    tag = "v${version}";
    hash = "sha256-1bjlw7sJB/1LdMD0R3h/8l1UK3cGMEz5WqVD0CMnTYY=";
  };

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  dotnet-runtime = dotnetCorePackages.runtime_8_0;
  dotnet-sdk = dotnetCorePackages.sdk_8_0;

  dotnetBuildFlags = [
    "-p:MinVerVersionOverride=${version}"
    # this is fragile with sdk updates
    "-p:EnforceCodeStyleInBuild=false"
  ];

  dotnetInstallFlags = [
    "--framework"
    "net8.0"
  ];

  executables = [ "Microsoft.Sbom.Tool" ];
  nugetDeps = ./deps.json;
  projectFile = "src/Microsoft.Sbom.Tool/Microsoft.Sbom.Tool.csproj";

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Highly scalable and enterprise ready tool to create SPDX 2.2 and SPDX 3.0 compatible SBOMs for any variety of artifacts";
    homepage = "https://github.com/microsoft/sbom-tool";
    changelog = "https://github.com/microsoft/sbom-tool/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
    mainProgram = "Microsoft.Sbom.Tool";
  };
}
