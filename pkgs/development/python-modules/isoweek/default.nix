{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "isoweek";
  version = "1.3.3";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-c/P3usRD4Fo6tFwypyBIsMTybVPYFGLsSxQsdYHT/+g=";
  };

  nativeCheckInputs = [ unittestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "isoweek" ];

  meta = {
    description = "Module work with ISO weeks";
    homepage = "https://github.com/gisle/isoweek";
    changelog = "https://github.com/gisle/isoweek/releases/tag/v${version}";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ mrmebelman ];
  };
}
