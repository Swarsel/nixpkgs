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
  pname = "pyfibaro";
  version = "0.8.3";

  src = fetchFromGitHub {
    owner = "rappenze";
    repo = "pyfibaro";
    tag = finalAttrs.version;
    hash = "sha256-KdlndW066TDxZpkIP0Oa3Lii0mBpwELfHtoGKiwh6GE=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    requests-mock
  ];

  build-system = [ setuptools ];
  dependencies = [ requests ];
  pyproject = true;
  pythonImportsCheck = [ "pyfibaro" ];

  meta = {
    description = "Library to access FIBARO Home center";
    homepage = "https://github.com/rappenze/pyfibaro";
    changelog = "https://github.com/rappenze/pyfibaro/releases/tag/${finalAttrs.src.tag}";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
})
