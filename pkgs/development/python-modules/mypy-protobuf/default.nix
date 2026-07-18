{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  grpcio-tools,
  mypy-protobuf,
  protobuf,
  pytestCheckHook,
  setuptools,
  testers,
  types-protobuf,
}:

buildPythonPackage (finalAttrs: {
  pname = "mypy-protobuf";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "nipunn1313";
    repo = "mypy-protobuf";
    rev = "47fa102ae5d2bd2a1fdde2adf94cf006a3e939a4"; # not tagged, but on pypi
    hash = "sha256-VYDTJmiezHAVC3QV+HM7C5y5WaFvoInzupWhnB/iNgA=";
  };

  doCheck = false; # ModuleNotFoundError: No module named 'testproto'
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    grpcio-tools
    protobuf
    types-protobuf
  ];

  pyproject = true;
  pythonImportsCheck = [ "mypy_protobuf" ];
  pythonRelaxDeps = [ "protobuf" ];

  passthru.tests.version = testers.testVersion {
    command = "${lib.getExe mypy-protobuf} --version";
    package = mypy-protobuf;
  };

  meta = {
    description = "Generate mypy stub files from protobuf specs";
    homepage = "https://github.com/nipunn1313/mypy-protobuf";
    changelog = "https://github.com/nipunn1313/mypy-protobuf/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "protoc-gen-mypy";
  };
})
