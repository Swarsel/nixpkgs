{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  lxml,
  setuptools,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "ezodf";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "T0ha";
    repo = "ezodf";
    tag = version;
    hash = "sha256-d66CTj9CpCnMICqNdUP07M9elEfoxuPg8x1kxqgXTTE=";
  };

  nativeCheckInputs = [
    unittestCheckHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    lxml
  ];

  pyproject = true;

  pythonImportsCheck = [
    "ezodf"
  ];

  unittestFlags = [
    "tests"
  ];

  meta = {
    description = "Extract, add, modify, or delete document data in OpenDocument (ODF) files";
    homepage = "https://github.com/T0ha/ezodf";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ zhaofengli ];
  };
}
