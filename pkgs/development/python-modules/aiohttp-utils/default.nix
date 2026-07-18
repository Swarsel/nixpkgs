{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  gunicorn,
  mako,
  pytestCheckHook,
  python-mimeparse,
  pythonAtLeast,
  setuptools,
  webtest-aiohttp,
}:

buildPythonPackage (finalAttrs: {
  pname = "aiohttp-utils";
  version = "3.2.1";

  src = fetchFromGitHub {
    owner = "sloria";
    repo = "aiohttp-utils";
    tag = finalAttrs.version;
    hash = "sha256-CGKka6nGQ9o4wn6o3YJ3hm8jGbg16NKkCdBA1mKz4bo=";
  };

  nativeCheckInputs = [
    mako
    pytestCheckHook
    webtest-aiohttp
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    aiohttp
    python-mimeparse
    gunicorn
  ];

  disabledTestPaths = lib.optionals (pythonAtLeast "3.14") [
    # RuntimeError: There is no current event loop in thread 'MainThread'.
    "tests/test_examples.py"
    "tests/test_negotiation.py"
    "tests/test_routing.py"
  ];

  disabledTests = [
    # AssertionError: assert None == 'application/octet-stream'
    "test_renders_to_json_by_default"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "aiohttp_utils"
  ];

  meta = {
    description = "Handy utilities for building aiohttp.web applications";
    homepage = "https://github.com/sloria/aiohttp-utils";
    changelog = "https://github.com/sloria/aiohttp-utils/tags/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
