{
  lib,
  fetchFromGitHub,
  buildGoModule,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "ddosify";
  version = "2.6.0";

  src = fetchFromGitHub {
    owner = "getanteon";
    repo = "anteon";
    tag = "selfhosted-${finalAttrs.version}";
    hash = "sha256-EPbpBCSaUVVhxGlj7gRqwHLuj5p6563iiARqkEjA6Rk=";
  };

  vendorHash = "sha256-Wg4JzA2aEwNBsDrkauFUb9AS38ITLBGex9QHzDcdpoM=";
  # TestCreateHammerMultipartPayload error occurred - Get "https://upload.wikimedia.org/wikipedia/commons/b/bd/Test.svg"
  doCheck = false;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-w"
    "-X=main.GitVersion=${finalAttrs.version}"
    "-X=main.GitCommit=unknown"
    "-X=main.BuildDate=unknown"
  ];

  sourceRoot = "${finalAttrs.src.name}/ddosify_engine";
  versionCheckProgramArg = "-version";

  meta = {
    description = "High-performance load testing tool, written in Golang";
    homepage = "https://ddosify.com/";
    changelog = "https://github.com/getanteon/anteon/releases/tag/selfhosted-${finalAttrs.version}";
    license = lib.licenses.agpl3Plus;
    maintainers = [ ];
    mainProgram = "ddosify";
  };
})
