{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  httpx,
  pytestCheckHook,
  requests,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "telegraph";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "python273";
    repo = "telegraph";
    tag = "v${finalAttrs.version}";
    hash = "sha256-xARX8lSOftNVYY4InR5vU4OiguCJJJZv/W76G9eLgNY=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ requests ];
  # Needs networking
  disabledTests = [ "test_get_page" ];
  enabledTestPaths = [ "tests/" ];

  optional-dependencies = {
    aio = [ httpx ];
  };

  pyproject = true;
  pythonImportsCheck = [ "telegraph" ];

  meta = {
    description = "Telegraph API wrapper";
    homepage = "https://github.com/python273/telegraph";
    changelog = "https://github.com/python273/telegraph/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ gp2112 ];
  };
})
