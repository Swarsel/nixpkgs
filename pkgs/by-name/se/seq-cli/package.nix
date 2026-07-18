{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
  testers,
}:

buildDotnetModule (finalAttrs: {
  pname = "seq-cli";
  version = "2024.3.922";

  src = fetchFromGitHub {
    owner = "datalust";
    repo = "seqcli";
    rev = "v${finalAttrs.version}";
    hash = "sha256-qqvuxG/QkkYjYw+p5QxLBWYHyltKDWT3JT167bEAdEI=";
  };

  dotnet-runtime = dotnetCorePackages.runtime_8_0;
  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnetInstallFlags = "-f net8.0";
  executables = [ "seqcli" ];
  nugetDeps = ./deps.json;
  projectFile = "src/SeqCli/SeqCli.csproj";

  passthru.tests.version = testers.testVersion {
    command = "seqcli version";
    package = finalAttrs.finalPackage;
  };

  meta = {
    description = "Seq command-line client. Administer, log, ingest, search, from any OS";
    homepage = "https://github.com/datalust/seqcli";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ hausken ];
    platforms = lib.platforms.all;
    mainProgram = "seqcli";
  };
})
