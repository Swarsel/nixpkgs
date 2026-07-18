{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytest,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "ansicolors";
  version = "1.1.8";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-mflPXjNIoLzUPILl/EQUATzMGdcL2TmtceATPOnDcuA=";
    extension = "zip";
  };

  nativeCheckInputs = [ pytest ];

  checkPhase = ''
    py.test
  '';

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "colors" ];

  meta = {
    description = "ANSI colors for Python";
    homepage = "https://github.com/verigak/colors/";
    changelog = "https://pypi.org/project/ansicolors/${finalAttrs.version}/";
    license = lib.licenses.isc;
    maintainers = [ ];
  };
})
