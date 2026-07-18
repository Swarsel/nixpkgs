{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  importlib-resources,
  numpy,
  pandas,
  patsy,
  # build-system
  poetry-core,
  # test
  pytestCheckHook,
  scikit-learn,
  scipy,
  setuptools,
  statsmodels,
}:
buildPythonPackage rec {
  pname = "category-encoders";
  version = "2.9.0";

  src = fetchFromGitHub {
    owner = "scikit-learn-contrib";
    repo = "category_encoders";
    tag = version;
    hash = "sha256-OcQCEWxqH6b9adQk64fdnqFl5CGLb9Yyd7bSxSaGTvg=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    poetry-core
    setuptools
  ];

  dependencies = [
    importlib-resources
    numpy
    pandas
    patsy
    scikit-learn
    scipy
    statsmodels
  ];

  pyproject = true;

  pythonImportsCheck = [
    "category_encoders"
  ];

  meta = {
    description = "Library for sklearn compatible categorical variable encoders";
    homepage = "https://github.com/scikit-learn-contrib/category_encoders";
    changelog = "https://github.com/scikit-learn-contrib/category_encoders/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ daspk04 ];
  };
}
