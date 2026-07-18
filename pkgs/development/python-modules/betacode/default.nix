{
  lib,
  buildPythonPackage,
  fetchPypi,
  isPy3k,
  pygtrie,
  setuptools,
}:
buildPythonPackage (finalAttrs: {
  pname = "betacode";
  version = "1.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-JZtnjozpAehzUZbSSMnCrUKjiOmQ/YOD+XLRtVObBGk=";
  };

  preBuild = "echo > README.rst";
  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ pygtrie ];
  # setup.py uses a python3 os.path.join
  disabled = !isPy3k;
  pyproject = true;
  pythonImportsCheck = [ "betacode" ];

  meta = {
    description = "Small python package to flexibly convert from betacode to unicode and back";
    homepage = "https://github.com/matgrioni/betacode";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kmein ];
  };
})
