{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  environs,
  httpx,
  pytest-asyncio,
  pytest-cov-stub,
  pytest-mock,
  pytest-vcr,
  pytestCheckHook,
  setuptools,
  tornado,
}:

buildPythonPackage (finalAttrs: {
  pname = "deezer-python";
  version = "7.3.0";

  src = fetchFromGitHub {
    owner = "browniebroke";
    repo = "deezer-python";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pCrPlEbt5Mx8qGjewR5+Z/W7rFEehqd7QRrtvPGyKJk=";
  };

  nativeCheckInputs = [
    environs
    pytest-asyncio
    pytest-cov-stub
    pytest-mock
    pytest-vcr
    pytestCheckHook
    tornado
  ];

  build-system = [ setuptools ];
  dependencies = [ httpx ];

  disabledTests = [
    # JSONDecodeError issue
    "test_get_user_flow"
    "test_with_language_header"
  ];

  pyproject = true;
  pythonImportsCheck = [ "deezer" ];

  meta = {
    description = "Python wrapper around the Deezer API";
    homepage = "https://github.com/browniebroke/deezer-python";
    changelog = "https://github.com/browniebroke/deezer-python/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
