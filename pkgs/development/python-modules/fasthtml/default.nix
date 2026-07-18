{
  lib,
  fetchFromGitHub,
  # dependencies
  beautifulsoup4,
  buildPythonPackage,
  fastcore,
  fastlite,
  httpx,
  # optional-dependencies
  ipython,
  itsdangerous,
  lxml,
  oauthlib,
  pyjwt,
  # tests
  pytestCheckHook,
  python-dateutil,
  python-multipart,
  # build-system
  setuptools,
  starlette,
  uvicorn,
  monsterui ? null, # TODO: package
  pysymbol-llm ? null, # TODO: package
}:

buildPythonPackage (finalAttrs: {
  pname = "fasthtml";
  version = "0.13.3";

  src = fetchFromGitHub {
    owner = "AnswerDotAI";
    repo = "fasthtml";
    tag = finalAttrs.version;
    hash = "sha256-PS5HGegC6pG/bJAGrKDsRYguBnNS9EDrZIjWvjErO4M=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    beautifulsoup4
    fastcore
    fastlite
    httpx
    itsdangerous
    oauthlib
    python-dateutil
    python-multipart
    starlette
    uvicorn
  ];

  disabledTests = [
    # https://github.com/AnswerDotAI/fasthtml/issues/835
    "test_get_toaster_with_typehint"
  ];

  optional-dependencies = {
    dev = [
      ipython
      lxml
      monsterui
      pyjwt
      pysymbol-llm
    ];
  };

  pyproject = true;

  pythonImportsCheck = [
    "fasthtml"
  ];

  meta = {
    description = "The fastest way to create an HTML app";
    homepage = "https://github.com/AnswerDotAI/fasthtml";
    changelog = "https://github.com/AnswerDotAI/fasthtml/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
})
