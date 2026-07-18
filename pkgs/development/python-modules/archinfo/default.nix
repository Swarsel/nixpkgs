{
  lib,
  fetchFromGitHub,
  backports-strenum,
  buildPythonPackage,
  pytestCheckHook,
  pythonOlder,
  setuptools,
}:

buildPythonPackage rec {
  pname = "archinfo";
  version = "9.2.154";

  src = fetchFromGitHub {
    owner = "angr";
    repo = "archinfo";
    tag = "v${version}";
    hash = "sha256-Vks7Rjd8x2zeHnJPs0laH56S4b8pnR1cK82SpK+XOgE=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  disabled = pythonOlder "3.12";
  pyproject = true;
  pythonImportsCheck = [ "archinfo" ];

  meta = {
    description = "Classes with architecture-specific information";
    homepage = "https://github.com/angr/archinfo";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ fab ];
  };
}
