{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  pysigma,
  pytestCheckHook,
  requests,
}:

buildPythonPackage (finalAttrs: {
  pname = "pysigma-backend-sqlite";
  version = "1.1.3";

  src = fetchFromGitHub {
    owner = "SigmaHQ";
    repo = "pySigma-backend-sqlite";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+QiRfuLdhRo8wlQG3EM2wGD1VhlauuMrbrX8NDflguA=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    requests
  ];

  build-system = [ poetry-core ];
  dependencies = [ pysigma ];
  pyproject = true;
  pythonImportsCheck = [ "sigma.backends.sqlite" ];
  pythonRelaxDeps = [ "pysigma" ];

  meta = {
    description = "Library to support sqlite for pySigma";
    homepage = "https://github.com/SigmaHQ/pySigma-backend-sqlite";
    changelog = "https://github.com/SigmaHQ/pySigma-backend-sqlite/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [ fab ];
  };
})
