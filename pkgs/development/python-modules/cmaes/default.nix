{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hypothesis,
  numpy,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "cmaes";
  version = "0.13.0";

  src = fetchFromGitHub {
    owner = "CyberAgentAILab";
    repo = "cmaes";
    tag = "v${version}";
    hash = "sha256-sH5iJ9iSWLniIRzKsUC9ODlmifIuJoIAkOPpmAQ6Hrs=";
  };

  nativeBuildInputs = [ setuptools ];
  propagatedBuildInputs = [ numpy ];

  nativeCheckInputs = [
    hypothesis
    pytestCheckHook
  ];

  disabledTests = [
    # Disable time-sensitive test
    "test_cma_tell"
  ];

  pyproject = true;
  pythonImportsCheck = [ "cmaes" ];

  meta = {
    description = "Python library for CMA evolution strategy";
    homepage = "https://github.com/CyberAgentAILab/cmaes";
    changelog = "https://github.com/CyberAgentAILab/cmaes/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
}
