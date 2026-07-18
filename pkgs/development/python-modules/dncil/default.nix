{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "dncil";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "mandiant";
    repo = "dncil";
    tag = "v${version}";
    hash = "sha256-bndkiXkIYTd071J+mgkmJmA+9J5yJ+9/oDfAypN7wYo=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "dncil" ];

  meta = {
    description = "Module to disassemble Common Intermediate Language (CIL) instructions";
    homepage = "https://github.com/mandiant/dncil";
    changelog = "https://github.com/mandiant/dncil/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
