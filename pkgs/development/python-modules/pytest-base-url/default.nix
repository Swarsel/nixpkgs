{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatch-vcs,
  hatchling,
  pytest,
  pytest-localserver,
  pytest-metadata,
  pytestCheckHook,
  requests,
}:

buildPythonPackage (finalAttrs: {
  pname = "pytest-base-url";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "pytest-dev";
    repo = "pytest-base-url";
    tag = finalAttrs.version;
    hash = "sha256-3P3Uk3QoznAtNODLjXFbeNn3AOfp9owWU2jqkxTEAa4=";
  };

  nativeBuildInputs = [
    hatchling
    hatch-vcs
  ];

  buildInputs = [ pytest ];
  propagatedBuildInputs = [ requests ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-localserver
    pytest-metadata
  ];

  __darwinAllowLocalNetworking = true;

  disabledTests = [
    # should be xfail? or mocking doesn't work
    "test_url_fails"
  ];

  enabledTestPaths = [ "tests" ];
  pyproject = true;
  pythonImportsCheck = [ "pytest_base_url" ];

  meta = {
    description = "Pytest plugin for URL based tests";
    homepage = "https://github.com/pytest-dev/pytest-base-url";
    changelog = "https://github.com/pytest-dev/pytest-base-url/blob/${finalAttrs.src.rev}/CHANGES.rst";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ sephi ];
  };
})
