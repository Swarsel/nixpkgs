{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "filecheck";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "AntonLydike";
    repo = "filecheck";
    tag = "v${version}";
    hash = "sha256-oOGQIEPIHL4xQRVKOw+8Z8QSowXlavVnck+IOWA9qd8=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ poetry-core ];
  pyproject = true;
  pythonImportsCheck = [ "filecheck" ];

  meta = {
    description = "Python-native clone of LLVMs FileCheck tool";
    homepage = "https://github.com/antonlydike/filecheck";
    changelog = "https://github.com/antonlydike/filecheck/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ yorickvp ];
    mainProgram = "filecheck";
  };
}
