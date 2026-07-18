{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "parsedatetime";
  version = "2.6";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-TLNo+7GKC3Ix9NdhGRZUUcjS41lRRV3+6XxiqHsE1FU=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  disabledTests = [
    # https://github.com/bear/parsedatetime/issues/263
    "testDate3ConfusedHourAndYear"
    # https://github.com/bear/parsedatetime/issues/215
    "testFloat"
  ];

  enabledTestPaths = [ "tests/Test*.py" ];
  pyproject = true;
  pythonImportsCheck = [ "parsedatetime" ];

  meta = {
    description = "Parse human-readable date/time text";
    homepage = "https://github.com/bear/parsedatetime";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
