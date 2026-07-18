{
  lib,
  fetchFromGitHub,
  anyio,
  buildPythonPackage,
  certifi,
  docling-core,
  fastapi,
  platformdirs,
  pluggy,
  poetry-core,
  pydantic,
  pydantic-settings,
  pytestCheckHook,
  python-dateutil,
  python-dotenv,
  requests,
  six,
  tabulate,
  tqdm,
  typer,
  urllib3,
  uvicorn,
}:

buildPythonPackage rec {
  pname = "deepsearch-toolkit";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "DS4SD";
    repo = "deepsearch-toolkit";
    tag = "v${version}";
    hash = "sha256-nrz9pvyA5gPIaKt6CsJOB9cLy3sXiWW5e1Rk4vtNIY8=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    poetry-core
  ];

  dependencies = [
    certifi
    docling-core
    platformdirs
    pluggy
    pydantic
    pydantic-settings
    python-dateutil
    python-dotenv
    requests
    six
    tabulate
    tqdm
    typer
    urllib3
  ];

  disabledTests = [
    # Tests require the creation of a deepsearch profile
    "test_project_listing"
    "test_system_info"
  ];

  optional-dependencies = rec {
    all = api;

    api = [
      anyio
      fastapi
      uvicorn
    ];
  };

  pyproject = true;

  pythonImportsCheck = [
    "deepsearch"
  ];

  pythonRelaxDeps = [
    "certifi"
    "urllib3"
  ];

  meta = {
    description = "Interact with the Deep Search platform for new knowledge explorations and discoveries";
    homepage = "https://github.com/DS4SD/deepsearch-toolkit";
    changelog = "https://github.com/DS4SD/deepsearch-toolkit/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
