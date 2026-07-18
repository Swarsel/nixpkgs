{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  chameleon,
  click,
  polib,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "lingva";
  version = "5.0.6";

  src = fetchFromGitHub {
    owner = "vacanza";
    repo = "lingva";
    tag = "v${version}";
    hash = "sha256-eGXUBSEO5n5WUENhJ+p5eKTdenBsONUWw1mDax7QcSA=";
  };

  nativeCheckInputs = [ pytestCheckHook ] ++ optional-dependencies.chameleon;
  build-system = [ setuptools ];

  dependencies = [
    click
    polib
  ];

  optional-dependencies = {
    chameleon = [ chameleon ];
  };

  pyproject = true;
  pythonImportsCheck = [ "lingva" ];

  meta = {
    description = "Module with tools to extract translatable texts from your code";
    homepage = "https://github.com/vacanza/lingva";
    changelog = "https://github.com/vacanza/lingva/blob/${src.tag}/changes.rst";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ fab ];
  };
}
