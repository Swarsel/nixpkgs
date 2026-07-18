{
  lib,
  fetchFromGitHub,
  appdirs,
  buildPythonPackage,
  hatch-vcs,
  hatchling,
  pytest-mock,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "platformdirs";
  version = "4.9.6";

  src = fetchFromGitHub {
    owner = "tox-dev";
    repo = "platformdirs";
    tag = version;
    hash = "sha256-/aoJquWRn1UQZa96uZba15tDO+IGEHN9/duu9JYXmd4=";
  };

  nativeCheckInputs = [
    appdirs
    pytest-mock
    pytestCheckHook
  ];

  preCheck = ''
    unset XDG_DATA_DIRS
  '';

  build-system = [
    hatchling
    hatch-vcs
  ];

  pyproject = true;
  pythonImportsCheck = [ "platformdirs" ];

  meta = {
    description = "Module for determining appropriate platform-specific directories";
    homepage = "https://platformdirs.readthedocs.io/";
    changelog = "https://github.com/tox-dev/platformdirs/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
