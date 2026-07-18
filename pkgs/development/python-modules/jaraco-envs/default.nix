{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  path,
  pytestCheckHook,
  setuptools-scm,
  tox,
  virtualenv,
}:

buildPythonPackage rec {
  pname = "jaraco-envs";
  version = "2.6.0";

  src = fetchFromGitHub {
    owner = "jaraco";
    repo = "jaraco.envs";
    tag = "v${version}";
    hash = "sha256-yRMX0H6yWN8TiO/LGAr4HyrVS8ZhBjuR885/+UQscP0=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools-scm ];

  dependencies = [
    path
    tox
    virtualenv
  ];

  disabledTestPaths = [
    # requires networking
    "jaraco/envs.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "jaraco.envs" ];

  meta = {
    description = "Classes for orchestrating Python (virtual) environments";
    homepage = "https://github.com/jaraco/jaraco.envs";
    changelog = "https://github.com/jaraco/jaraco.envs/blob/${src.rev}/NEWS.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
