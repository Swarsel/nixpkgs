{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  pytestCheckHook,
  setuptools,
}:
buildPythonPackage rec {
  pname = "stackprinter";
  version = "0.2.13";

  src = fetchFromGitHub {
    owner = "cknd";
    repo = "stackprinter";
    tag = version;
    hash = "sha256-R6s1YBbb52oK1zIQtRR80W+6Ca/gATtC6S3rUEC4Mes=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    numpy
  ];

  pyproject = true;

  pythonImportsCheck = [
    "stackprinter"
    "stackprinter.colorschemes"
    "stackprinter.extraction"
    "stackprinter.formatting"
    "stackprinter.frame_formatting"
    "stackprinter.prettyprinting"
    "stackprinter.source_inspection"
    "stackprinter.tracing"
    "stackprinter.utils"
  ];

  meta = {
    description = "Debugging-friendly exceptions for Python";
    homepage = "https://github.com/cknd/stackprinter";
    changelog = "https://github.com/cknd/stackprinter/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.ryand56 ];
  };
}
