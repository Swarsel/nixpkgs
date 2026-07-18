{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pandas,
  pytest-cov-stub,
  pytest-mock,
  pytestCheckHook,
  scikit-learn,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "kotsu";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "datavaluepeople";
    repo = "kotsu";
    tag = "v${version}";
    hash = "sha256-7bRrHowRKq3xiBiAkfS4ZL9PXHIUmZc99q9pHex9BLg=";
  };

  propagatedBuildInputs = [
    pandas
    typing-extensions
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
    pytest-mock
    scikit-learn
  ];

  format = "setuptools";
  pythonImportsCheck = [ "kotsu" ];

  meta = {
    description = "Lightweight framework for structured and repeatable model validation";
    homepage = "https://github.com/datavaluepeople/kotsu";
    changelog = "https://github.com/datavaluepeople/kotsu/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
