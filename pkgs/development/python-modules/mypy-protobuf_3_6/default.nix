{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  grpcio-tools,
  protobuf,
  pytestCheckHook,
  setuptools,
  types-protobuf,
  versionCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "mypy-protobuf";
  version = "3.6.0";

  src = fetchFromGitHub {
    owner = "nipunn1313";
    repo = "mypy-protobuf";
    tag = "v${finalAttrs.version}";
    hash = "sha256-YBm/qfmas0kPmzhlgAwCdT8nsnC45fj2bhK3cXpvANo=";
  };

  doCheck = false; # ModuleNotFoundError: No module named 'testproto'
  nativeCheckInputs = [ pytestCheckHook ];
  nativeInstallCheckInputs = [ versionCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    grpcio-tools
    protobuf
    types-protobuf
  ];

  # nixpkgs-update: no auto update
  # this is a pinned version
  pyproject = true;
  pythonImportsCheck = [ "mypy_protobuf" ];
  pythonRelaxDeps = [ "protobuf" ];

  meta = {
    description = "Generate mypy stub files from protobuf specs";
    homepage = "https://github.com/nipunn1313/mypy-protobuf";
    changelog = "https://github.com/nipunn1313/mypy-protobuf/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ sigmanificient ];
    mainProgram = "protoc-gen-mypy";
  };
})
