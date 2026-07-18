{
  lib,
  fetchFromGitHub,
  bidict,
  bubop,
  buildPythonPackage,
  poetry-core,
}:

buildPythonPackage rec {
  pname = "item-synchronizer";
  version = "1.1.5";

  src = fetchFromGitHub {
    owner = "bergercookie";
    repo = "item_synchronizer";
    rev = "v${version}";
    hash = "sha256-+mviKtCLlJhYV576Q07kcFJvtls5qohKSrqZtBqE/s4=";
  };

  nativeBuildInputs = [ poetry-core ];

  propagatedBuildInputs = [
    bidict
    bubop
  ];

  pyproject = true;
  pythonImportsCheck = [ "item_synchronizer" ];

  pythonRelaxDeps = [
    "bidict"
    "bubop"
  ];

  meta = {
    description = "";
    homepage = "https://github.com/bergercookie/item_synchronizer";
    changelog = "https://github.com/bergercookie/item_synchronizer/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
