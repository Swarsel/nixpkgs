{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools-scm,
  toml,
}:

buildPythonPackage rec {
  pname = "pure-eval";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "alexmojaki";
    repo = "pure_eval";
    rev = "v${version}";
    hash = "sha256-gdP8/MkzTyjkZaWUG5PoaOtBqzbCXYNYBX2XBLWLh18=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools-scm ];
  dependencies = [ toml ];
  format = "setuptools";
  pythonImportsCheck = [ "pure_eval" ];

  meta = {
    description = "Safely evaluate AST nodes without side effects";
    homepage = "https://github.com/alexmojaki/pure_eval";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
