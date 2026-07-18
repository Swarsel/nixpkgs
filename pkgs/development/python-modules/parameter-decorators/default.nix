{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "parameter-decorators";
  version = "0.0.2";

  src = fetchFromGitHub {
    owner = "matan1008";
    repo = "parameter-decorators";
    tag = "v${version}";
    hash = "sha256-ZTgUsBc2ArnRPR4k0Od2A571iFfu+oupCxEqzk2cTUQ=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "parameter_decorators" ];

  meta = {
    description = "Handy decorators for converting parameters";
    homepage = "https://github.com/matan1008/parameter-decorators";
    changelog = "https://github.com/matan1008/parameter-decorators/releases/tag/${src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.dotlambda ];
  };
}
