{
  lib,
  fetchFromGitHub,
  blessed,
  buildPythonPackage,
  editor,
  pexpect,
  poetry-core,
  pytestCheckHook,
  readchar,
}:

buildPythonPackage rec {
  pname = "inquirer3";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "guysalt";
    repo = "python-inquirer3";
    tag = "v${version}";
    hash = "sha256-IReJlwVgjTlTlD0xTVWrzQ0ITvCQvPJ86zCmffaoPk4=";
  };

  nativeCheckInputs = [
    pexpect
    pytestCheckHook
  ];

  build-system = [ poetry-core ];

  dependencies = [
    blessed
    editor
    readchar
  ];

  pyproject = true;
  pythonImportsCheck = [ "inquirer3" ];

  meta = {
    description = "Collection of common interactive command line user interfaces, based on Inquirer.js";
    homepage = "https://github.com/guysalt/python-inquirer3";
    changelog = "https://github.com/guysalt/python-inquirer3/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.dotlambda ];
  };
}
