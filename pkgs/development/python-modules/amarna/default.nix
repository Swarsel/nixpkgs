{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  lark,
  pydot,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "amarna";
  version = "0.1.5";

  src = fetchFromGitHub {
    owner = "crytic";
    repo = "amarna";
    tag = "v${version}";
    hash = "sha256-tyvHWBhanR7YH87MDWdXUsDEzZG6MgnbshezAbxWO+I=";
  };

  propagatedBuildInputs = [
    lark
    pydot
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  format = "setuptools";
  pythonImportsCheck = [ "amarna" ];

  meta = {
    description = "Static-analyzer and linter for the Cairo programming language";
    homepage = "https://github.com/crytic/amarna";
    license = lib.licenses.agpl3Only;
    maintainers = [ ];
    mainProgram = "amarna";
  };
}
