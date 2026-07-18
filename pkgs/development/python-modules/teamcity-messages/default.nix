{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "teamcity-messages";
  version = "1.33";

  src = fetchFromGitHub {
    owner = "JetBrains";
    repo = "teamcity-messages";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BAwAfe54J+gbbiz03Yiu3eC/9RnI7P0mfR3nfM1oKZw=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  enabledTestPaths = [ "tests/unit-tests/" ];
  pyproject = true;
  pythonImportsCheck = [ "teamcity" ];

  meta = {
    description = "Python unit test reporting to TeamCity";
    homepage = "https://github.com/JetBrains/teamcity-messages";
    changelog = "https://github.com/JetBrains/teamcity-messages/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
