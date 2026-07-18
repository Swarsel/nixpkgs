{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "kgb";
  version = "7.2";

  src = fetchFromGitHub {
    owner = "beanbaginc";
    repo = "kgb";
    tag = "release-${version}";
    hash = "sha256-hNJXoUIyrCB9PCWLCmN81F6pBRwZApDR6JWA0adyklw=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "kgb" ];

  meta = {
    description = "Python function spy support for unit tests";
    homepage = "https://github.com/beanbaginc/kgb";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
