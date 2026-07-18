{
  lib,
  buildPythonPackage,
  curio,
  fetchPypi,
  glibcLocales,
  isPy3k,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "sniffio";
  version = "1.3.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-9DJO3GcKD0l1CoG4lfNcOtuEPMpG8FMPefwbq7I3idw=";
  };

  buildInputs = [ glibcLocales ];

  nativeCheckInputs = [
    curio
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  disabled = !isPy3k;
  pyproject = true;

  meta = {
    description = "Sniff out which async library your code is running under";
    homepage = "https://github.com/python-trio/sniffio";
    license = lib.licenses.asl20;
  };
}
