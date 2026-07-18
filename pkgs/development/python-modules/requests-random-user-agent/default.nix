{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest-httpbin,
  pytestCheckHook,
  requests,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "requests-random-user-agent";
  version = "2025.01.19";

  src = fetchFromGitHub {
    owner = "DavidWittman";
    repo = "requests-random-user-agent";
    tag = finalAttrs.version;
    hash = "sha256-El/aibqEyx5diVTOe/4PEFB7KRfKqUJGPar6j6hZyIc=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ requests ];

  disabledTests = [
    # Tests require network access
    "test_request"
    "test_request_different_without_session"
    "test_request_without_session"
  ];

  pyproject = true;
  pythonImportsCheck = [ "requests_random_user_agent" ];

  meta = {
    description = "Configures the requests library to randomly select a desktop User-Agent";
    homepage = "https://github.com/DavidWittman/requests-random-user-agent";
    changelog = "https://github.com/DavidWittman/requests-random-user-agent/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
