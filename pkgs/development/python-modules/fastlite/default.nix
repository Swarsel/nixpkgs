{
  lib,
  fetchFromGitHub,
  apswutils,
  buildPythonPackage,
  # dependencies
  fastcore,
  # build-system
  setuptools_80,
}:

buildPythonPackage (finalAttrs: {
  pname = "fastlite";
  version = "0.2.4";

  src = fetchFromGitHub {
    owner = "AnswerDotAI";
    repo = "fastlite";
    tag = finalAttrs.version;
    hash = "sha256-q2eGP/GRWqgbvWOVuLch33VkYbedeDRsxsnN+xsevPI=";
  };

  # No tests
  doCheck = false;

  build-system = [
    setuptools_80
  ];

  dependencies = [
    fastcore
    apswutils
  ];

  pyproject = true;

  pythonImportsCheck = [
    "fastlite"
  ];

  meta = {
    description = "A bit of extra usability for sqlite";
    homepage = "https://github.com/AnswerDotAI/fastlite";
    changelog = "https://github.com/AnswerDotAI/fastlite/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
})
