{
  lib,
  fetchFromGitHub,
  ascii-magic,
  buildPythonPackage,
  oauthlib,
  pillow,
  pyjwt,
  pytest-cov-stub,
  pytestCheckHook,
  requests,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "weconnect";
  version = "0.60.11";

  src = fetchFromGitHub {
    owner = "tillsteinbach";
    repo = "WeConnect-python";
    tag = "v${finalAttrs.version}";
    hash = "sha256-llAWCjhP/fwI+H8BRpMYxba8jC+WDc66xkUDwT3NHcA=";
  };

  postPatch = ''
    substituteInPlace weconnect/__version.py \
      --replace-fail "0.0.0dev" "${finalAttrs.version}"
    substituteInPlace setup.py \
      --replace-fail "setup_requires=SETUP_REQUIRED" "setup_requires=[]" \
      --replace-fail "tests_require=TEST_REQUIRED" "tests_require=[]"
    substituteInPlace pytest.ini \
      --replace-fail "required_plugins = pytest-cov" ""
  '';

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    oauthlib
    pyjwt
    requests
  ];

  optional-dependencies = {
    Images = [
      ascii-magic
      pillow
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "weconnect" ];

  pythonRelaxDeps = [
    "oauthlib"
    "requests"
  ];

  meta = {
    description = "Python client for the Volkswagen WeConnect Services";
    homepage = "https://github.com/tillsteinbach/WeConnect-python";
    changelog = "https://github.com/tillsteinbach/WeConnect-python/releases/tag/v${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
