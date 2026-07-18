{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  colorama,
  docstring-parser,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "targ";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "piccolo-orm";
    repo = "targ";
    tag = version;
    hash = "sha256-myQe8Gpnx5CqKnYNK0PZ2P7o+eVWKLInjyTaZd30WxU=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    colorama
    docstring-parser
  ];

  pyproject = true;
  pythonImportsCheck = [ "targ" ];

  meta = {
    description = "Python CLI using type hints and docstrings";
    homepage = "https://github.com/piccolo-orm/targ/";
    changelog = "https://github.com/piccolo-orm/targ/blob/${src.tag}/CHANGES.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
