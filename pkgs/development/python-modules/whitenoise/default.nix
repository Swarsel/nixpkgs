{
  lib,
  fetchFromGitHub,
  brotli,
  buildPythonPackage,
  django,
  pytestCheckHook,
  requests,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "whitenoise";
  version = "6.12.0";

  src = fetchFromGitHub {
    owner = "evansd";
    repo = "whitenoise";
    tag = finalAttrs.version;
    hash = "sha256-qNya/3oI9413VUGaLPq4vtuLvq9mIGhaYBt+4OhrkOw=";
  };

  nativeCheckInputs = [
    django
    pytestCheckHook
    requests
  ]
  ++ finalAttrs.passthru.optional-dependencies.brotli;

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  disabledTests = [
    # Test fails with AssertionError
    "test_modified"
  ];

  optional-dependencies.brotli = [ brotli ];
  pyproject = true;
  pythonImportsCheck = [ "whitenoise" ];

  meta = {
    description = "Library to serve static file for WSGI applications";
    homepage = "https://whitenoise.readthedocs.io/";
    changelog = "https://github.com/evansd/whitenoise/blob/${finalAttrs.src.tag}/docs/changelog.rst";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
