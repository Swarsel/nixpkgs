{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cryptography,
  olefile,
  poetry-core,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "msoffcrypto-tool";
  version = "6.0.0";

  src = fetchFromGitHub {
    owner = "nolze";
    repo = "msoffcrypto-tool";
    tag = "v${finalAttrs.version}";
    hash = "sha256-qhnQXLkEeMfuPl2FJGX19M2B+StlzGU/wHgmRn9jcxc=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ poetry-core ];

  dependencies = [
    cryptography
    olefile
    setuptools
  ];

  disabledTests = [
    # Test fails with AssertionError
    "test_cli"
  ];

  pyproject = true;
  pythonImportsCheck = [ "msoffcrypto" ];

  meta = {
    description = "Python tool and library for decrypting MS Office files with passwords or other keys";
    homepage = "https://github.com/nolze/msoffcrypto-tool";
    changelog = "https://github.com/nolze/msoffcrypto-tool/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "msoffcrypto-tool";
  };
})
