{
  lib,
  fetchFromGitHub,
  # dependencies
  apsw,
  buildPythonPackage,
  fastcore,
  hypothesis,
  # tests
  pytestCheckHook,
  # build-system
  setuptools_80,
}:

buildPythonPackage (finalAttrs: {
  pname = "apswutils";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "AnswerDotAI";
    repo = "apswutils";
    tag = finalAttrs.version;
    hash = "sha256-lqtgjQ4nhmcf52mFeXdFxvd8WNsDDR9PEeWAncBX46g=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    hypothesis
  ];

  build-system = [
    setuptools_80
  ];

  dependencies = [
    apsw
    fastcore
  ];

  pyproject = true;

  pythonImportsCheck = [
    "apswutils"
  ];

  meta = {
    description = "A fork of sqlite-minutils for apsw";
    homepage = "https://github.com/AnswerDotAI/apswutils";
    changelog = "https://github.com/AnswerDotAI/apswutils/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
})
