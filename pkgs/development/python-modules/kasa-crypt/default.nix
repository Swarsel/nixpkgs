{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  poetry-core,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "kasa-crypt";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "bdraco";
    repo = "kasa-crypt";
    tag = "v${version}";
    hash = "sha256-rSRLrlV3QLatI2G8sd2jDwd6U8k4MrJil62ki1kNEMc=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  build-system = [
    cython
    poetry-core
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "kasa_crypt" ];

  meta = {
    description = "Fast kasa crypt";
    homepage = "https://github.com/bdraco/kasa-crypt";
    changelog = "https://github.com/bdraco/kasa-crypt/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
