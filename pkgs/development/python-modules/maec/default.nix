{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cybox,
  distutils,
  lxml,
  mixbox,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "maec";
  version = "4.1.0.17";

  src = fetchFromGitHub {
    owner = "MAECProject";
    repo = "python-maec";
    tag = "v${version}";
    hash = "sha256-I2Ov2AQiC9D8ivHqn7owcTsNS7Kw+CWVyijK3VO52Og=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    distutils
    setuptools
  ];

  dependencies = [
    cybox
    lxml
    mixbox
  ];

  pyproject = true;
  pythonImportsCheck = [ "maec" ];

  meta = {
    description = "Library for parsing, manipulating, and generating MAEC content";
    homepage = "https://github.com/MAECProject/python-maec/";
    changelog = "https://github.com/MAECProject/python-maec/blob/${src.rev}/CHANGES.txt";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ fab ];
  };
}
