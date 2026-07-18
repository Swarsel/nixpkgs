{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  editables,
  gitMinimal,
  mercurial,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pdm-backend";
  version = "2.4.9";

  src = fetchFromGitHub {
    owner = "pdm-project";
    repo = "pdm-backend";
    tag = version;
    hash = "sha256-082ZSfRUGUV8DX+vuJeOd+HOuAfnKfZPZ3Lyhx6TRlE=";
  };

  env.PDM_BUILD_SCM_VERSION = version;

  nativeCheckInputs = [
    editables
    gitMinimal
    mercurial
    pytestCheckHook
    setuptools
  ];

  preCheck = ''
    unset PDM_BUILD_SCM_VERSION

    # tests require a configured git identity
    export HOME=$TMPDIR
    git config --global user.name nixbld
    git config --global user.email nixbld@localhost
  '';

  pyproject = true;
  pythonImportsCheck = [ "pdm.backend" ];
  setupHook = ./setup-hook.sh;

  meta = {
    description = "Yet another PEP 517 backend";
    homepage = "https://github.com/pdm-project/pdm-backend";
    changelog = "https://github.com/pdm-project/pdm-backend/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
