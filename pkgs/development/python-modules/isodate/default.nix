{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "isodate";
  version = "0.7.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-TNGqD0PKdvSmxsApKoX0CzXsLkPjFbWfBubTIXGpU+Y=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  pyproject = true;

  meta = {
    description = "ISO 8601 date/time parser";
    homepage = "https://github.com/gweis/isodate/";
    changelog = "https://github.com/gweis/isodate/blob/${version}/CHANGES.txt";
    license = lib.licenses.bsd0;
  };
}
