{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  grpcio,
  protobuf,
  pytest-asyncio,
  pytest-cov-stub,
  pytest-mock,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "aetcd";
  version = "1.0.0a4";

  src = fetchFromGitHub {
    owner = "martyanov";
    repo = "aetcd";
    tag = "v${version}";
    hash = "sha256-g49ppfh8dyGpZeu/HdTDX8RAk5VTcZmqENRpNY12qkg=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail "setuptools_scm==6.3.2" "setuptools_scm"
  '';

  nativeCheckInputs = [
    pytest-asyncio
    pytest-cov-stub
    pytest-mock
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    grpcio
    protobuf
  ];

  disabledTestPaths = [
    # Tests require a running ectd instance
    "tests/integration/"
  ];

  pyproject = true;
  pythonImportsCheck = [ "aetcd" ];
  pythonRelaxDeps = [ "protobuf" ];

  meta = {
    description = "Python asyncio-based client for etcd";
    homepage = "https://github.com/martyanov/aetcd";
    changelog = "https://github.com/martyanov/aetcd/blob/v${version}/docs/changelog.rst";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
