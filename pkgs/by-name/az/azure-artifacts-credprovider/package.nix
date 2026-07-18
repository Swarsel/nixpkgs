{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
  nix-update-script,
}:
buildDotnetModule rec {
  pname = "azure-artifacts-credprovider";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "artifacts-credprovider";
    rev = "v${version}";
    sha256 = "sha256-rllLLSSebnnmsBtj+oj5FK6qyh4qPf0Zn7fKCnhrHpQ=";
  };

  dotnet-runtime = dotnetCorePackages.runtime_8_0;
  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  nugetDeps = ./deps.json;

  patchPhase = ''
    sed -i 's|<TargetFrameworks>.*</TargetFrameworks>|<TargetFramework>net8.0</TargetFramework>|' Build.props
  '';

  projectFile = "CredentialProvider.Microsoft/CredentialProvider.Microsoft.csproj";
  testProjectFile = "CredentialProvider.Microsoft.Tests/CredentialProvider.Microsoft.Tests.csproj";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Azure Artifacts Credential Provider";
    homepage = "https://github.com/microsoft/artifacts-credprovider";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ anpin ];
    platforms = lib.platforms.unix;
    mainProgram = "CredentialProvider.Microsoft";
  };
}
