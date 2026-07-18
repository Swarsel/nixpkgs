{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  nltk,
  pyphen,
  pytest,
  pytestCheckHook,
  setuptools,
}:
buildPythonPackage (finalAttrs: {
  pname = "textstat";
  version = "0.7.13";

  src = fetchFromGitHub {
    owner = "textstat";
    repo = "textstat";
    tag = finalAttrs.version;
    hash = "sha256-VMWwhwyGMFaKNLHoDG3gw1/jzSYCDBH3Yq4pE4JZTTo=";
  };

  env.NLTK_DATA = nltk.data.cmudict;

  nativeCheckInputs = [
    pytestCheckHook
    pytest
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    setuptools
    pyphen
    nltk
  ];

  enabledTestPaths = [
    "tests/"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "textstat"
  ];

  meta = {
    description = "Python package to calculate readability statistics of a text object";
    homepage = "https://textstat.org";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ aleksana ];
  };
})
