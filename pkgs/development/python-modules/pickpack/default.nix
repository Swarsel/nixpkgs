{
  lib,
  fetchFromGitHub,
  anytree,
  buildPythonPackage,
  poetry-core,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pickpack";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "anafvana";
    repo = "pickpack";
    rev = "v${version}";
    hash = "sha256-IUIs+Cgl2fvjSougyVSzhmY2SeEYL2T2ODrBWBg3zZM=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    poetry-core
  ];

  dependencies = [
    anytree
  ];

  pyproject = true;

  pythonImportsCheck = [
    "pickpack"
  ];

  meta = {
    description = "Curses-based (and pick-based) interactive picker for the terminal. Now covering trees also";
    homepage = "https://github.com/anafvana/pickpack";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
}
