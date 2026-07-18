{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  diffimg,
  imgdiff,
  pytestCheckHook,
  recommonmark,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "pytest-image-diff";
  version = "0.0.14";

  src = fetchFromGitHub {
    owner = "Apkawa";
    repo = "pytest-image-diff";
    tag = "v${version}";
    hash = "sha256-BQwEbZBgjnx5becu5dcDx0yiw3Y2qptwyqywFq6lqas=";
  };

  propagatedBuildInputs = [
    typing-extensions
    diffimg
    imgdiff
  ];

  nativeCheckInputs = [
    pytestCheckHook
    recommonmark
  ];

  format = "setuptools";
  pythonImportsCheck = [ "pytest_image_diff" ];

  meta = {
    description = "Pytest helps for compare images and regression";
    homepage = "https://github.com/Apkawa/pytest-image-diff";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
