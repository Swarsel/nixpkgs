{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "pytest-raises";
  version = "0.11";

  src = fetchFromGitHub {
    owner = "Lemmons";
    repo = "pytest-raises";
    tag = finalAttrs.version;
    hash = "sha256-wmtWPWwe1sFbWSYxs5ZXDUZM1qvjRGMudWdjQeskaz0=";
  };

  buildInputs = [ pytest ];
  nativeCheckInputs = [ pytestCheckHook ];

  disabledTests = [
    # Failed: nomatch: '*::test_pytest_mark_raises_unexpected_exception FAILED*'
    # https://github.com/Lemmons/pytest-raises/issues/30
    "test_pytest_mark_raises_unexpected_exception"
    "test_pytest_mark_raises_unexpected_match"
    "test_pytest_mark_raises_parametrize"
  ];

  format = "setuptools";
  pythonImportsCheck = [ "pytest_raises" ];

  meta = {
    description = "Implementation of pytest.raises as a pytest.mark fixture";
    homepage = "https://github.com/Lemmons/pytest-raises";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
})
