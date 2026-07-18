{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatch-vcs,
  hatchling,
  in-n-out,
  psygnal,
  pydantic,
  pydantic-compat,
  pytestCheckHook,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "app-model";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "pyapp-kit";
    repo = "app-model";
    tag = "v${finalAttrs.version}";
    hash = "sha256-zKaCxozT6OOPfrXMDic5d5DMb/I9tTiJFlX21Cc1yjY=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    hatch-vcs
    hatchling
  ];

  dependencies = [
    psygnal
    pydantic
    pydantic-compat
    in-n-out
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "app_model" ];

  meta = {
    description = "Module to implement generic application schema";
    homepage = "https://github.com/pyapp-kit/app-model";
    changelog = "https://github.com/pyapp-kit/app-model/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ fab ];
  };
})
