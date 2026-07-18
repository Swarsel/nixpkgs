{
  lib,
  buildPythonPackage,
  fetchPypi,
  psutil,
  setuptools,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "pyperf";
  version = "2.10.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-3ZPM/aeSFHJSk+lfH6bgDLSmStzxMmA5SG1OH5HKqmI=";
  };

  nativeBuildInputs = [ setuptools ];
  propagatedBuildInputs = [ psutil ];
  nativeCheckInputs = [ unittestCheckHook ];
  pyproject = true;
  pythonImportsCheck = [ "pyperf" ];

  unittestFlagsArray = [
    "-s"
    "pyperf/tests/"
    "-v"
  ];

  meta = {
    description = "Python module to generate and modify perf";
    homepage = "https://pyperf.readthedocs.io/";
    changelog = "https://github.com/psf/pyperf/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "pyperf";
  };
}
