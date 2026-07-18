{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  packaging,
  poetry-core,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "requirements-parser";
  version = "0.13.1";

  src = fetchFromGitHub {
    owner = "madpah";
    repo = "requirements-parser";
    tag = "v${version}";
    hash = "sha256-Hti1r/OLYHue+c7/TDDRzBgKxJazobZG+aFxK2ok70g=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ poetry-core ];

  dependencies = [
    packaging
  ];

  pyproject = true;
  pythonImportsCheck = [ "requirements" ];

  meta = {
    description = "Pip requirements file parser";
    homepage = "https://github.com/davidfischer/requirements-parser";
    changelog = "https://github.com/madpah/requirements-parser/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.bsd2;
    maintainers = [ ];
  };
}
