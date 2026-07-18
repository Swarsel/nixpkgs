{
  lib,
  fetchFromGitHub,
  asgineer,
  bcrypt,
  buildPythonPackage,
  iptools,
  itemdb,
  jinja2,
  markdown,
  nodejs,
  pscript,
  pyjwt,
  pytestCheckHook,
  pythonAtLeast,
  requests,
  setuptools,
  uvicorn,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "timetagger";
  version = "26.1.3";

  src = fetchFromGitHub {
    owner = "almarklein";
    repo = "timetagger";
    tag = "v${finalAttrs.version}";
    hash = "sha256-X82Ai6E844deRGs6KcJATEid3X6IlDq4+LCEU4lc4hM=";
  };

  nativeCheckInputs = [
    nodejs
    pytestCheckHook
    requests
    writableTmpDirAsHomeHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    asgineer
    bcrypt
    iptools
    itemdb
    jinja2
    markdown
    pscript
    pyjwt
    uvicorn
  ];

  disabledTestPaths = lib.optionals (pythonAtLeast "3.14") [
    #  RuntimeError: There is no current event loop in thread 'MainThread'
    "tests/test_server_apiserver.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "timetagger" ];

  meta = {
    description = "Library to interact with TimeTagger";
    homepage = "https://github.com/almarklein/timetagger";
    changelog = "https://github.com/almarklein/timetagger/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ matthiasbeyer ];
    mainProgram = "timetagger";
  };
})
