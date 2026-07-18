{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  gitUpdater,
  pytest,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pytest-unmagic";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "dimagi";
    repo = "pytest-unmagic";
    tag = "v${version}";
    hash = "sha256-M7eTZmLkSm1XGgF3ijzenkXcy8zBawauM9+AUxA9RDg=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    flit-core
  ];

  dependencies = [ pytest ];
  pyproject = true;
  pythonImportsCheck = [ "unmagic" ];
  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  meta = {
    description = "Pytest fixtures with conventional import semantics";
    homepage = "https://github.com/dimagi/pytest-unmagic";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
}
