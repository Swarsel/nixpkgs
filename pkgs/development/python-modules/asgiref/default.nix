{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "asgiref";
  version = "3.11.1";

  src = fetchFromGitHub {
    owner = "django";
    repo = "asgiref";
    tag = finalAttrs.version;
    hash = "sha256-Mhnaowgv5a+O2hN0ZSdtdhCBQx8HoKSwtRC3gHodgKY=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];
  dependencies = [ typing-extensions ];
  disabledTests = lib.optionals stdenv.hostPlatform.isDarwin [ "test_multiprocessing" ];
  pyproject = true;
  pythonImportsCheck = [ "asgiref" ];

  meta = {
    description = "Reference ASGI adapters and channel layers";
    homepage = "https://github.com/django/asgiref";
    changelog = "https://github.com/django/asgiref/blob/${finalAttrs.src.tag}/CHANGELOG.txt";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ miniharinn ];
  };
})
