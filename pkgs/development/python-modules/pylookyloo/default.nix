{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  lookyloo-models,
  poetry-core,
  pydantic,
  requests,
  urllib3,
}:

buildPythonPackage (finalAttrs: {
  pname = "pylookyloo";
  version = "1.40.0";

  src = fetchFromGitHub {
    owner = "Lookyloo";
    repo = "PyLookyloo";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2SeEAzVMS4tyOU2WZw7wx+fOgyKnrQxMb6dJRjbSplU=";
  };

  # Tests are outdated
  doCheck = false;
  build-system = [ poetry-core ];

  dependencies = [
    lookyloo-models
    pydantic
    requests
    urllib3
  ];

  pyproject = true;
  pythonImportsCheck = [ "pylookyloo" ];

  meta = {
    description = "Python CLI and module for Lookyloo";
    homepage = "https://github.com/Lookyloo/PyLookyloo";
    changelog = "https://github.com/Lookyloo/PyLookyloo/releases/tag/${finalAttrs.src.tag}";

    license = with lib.licenses; [
      bsd3
      gpl2Plus
    ];

    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "lookyloo";
  };
})
