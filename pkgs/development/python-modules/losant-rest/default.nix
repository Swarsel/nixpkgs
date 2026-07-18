{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  requests,
  requests-mock,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "losant-rest";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "Losant";
    repo = "losant-rest-python";
    tag = "v${finalAttrs.version}";
    hash = "sha256-nAc+zTqgIdLw/NVWoprP+Kqkbu17N1DMgzo2iu7w8aM=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    requests-mock
  ];

  build-system = [ setuptools ];
  dependencies = [ requests ];
  enabledTestPaths = [ "tests/losant_rest_test.py" ];
  pyproject = true;
  pythonImportsCheck = [ "losant_rest" ];

  meta = {
    description = "Python module for consuming the Losant IoT Platform API";
    homepage = "https://github.com/Losant/losant-rest-python";
    changelog = "https://github.com/Losant/losant-rest-python/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
