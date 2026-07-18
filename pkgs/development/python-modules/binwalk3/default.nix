{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "binwalk3";
  version = "3.1.3";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-Ro1HkQGg6BBu2nm5IfpWiu8XESCCQI/XOsvWLeoonQI=";
  };

  # Tests are not available on PyPI
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "binwalk" ];

  meta = {
    description = "Binwalk v3 with v2-compatible Python API";
    homepage = "https://pypi.org/project/binwalk3/";
    changelog = "https://github.com/ZachFlint/Binwalk3/blob/master/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
