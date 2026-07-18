{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  matplotlib,
  numpy,
  pytest-cov-stub,
  pytestCheckHook,
  seaborn,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pycm";
  version = "4.6";

  src = fetchFromGitHub {
    owner = "sepandhaghighi";
    repo = "pycm";
    tag = "v${version}";
    hash = "sha256-Yi82FBy+kUPKSXS8X6EOK+6hmR0xZgwlGqFjvc9bYEY=";
  };

  postPatch = ''
    # Remove a trivial dependency on the author's `art` Python ASCII art library
    rm pycm/__main__.py
    substituteInPlace setup.py \
      --replace-fail '=get_requires()' '=[]'
  '';

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
    matplotlib
  ];

  build-system = [ setuptools ];

  dependencies = [
    matplotlib
    numpy
    seaborn
  ];

  disabledTests = [
    "plot_error_test" # broken doctest (expects matplotlib import exception)
  ];

  pyproject = true;
  pythonImportsCheck = [ "pycm" ];

  meta = {
    description = "Multiclass confusion matrix library";
    homepage = "https://pycm.io";
    changelog = "https://github.com/sepandhaghighi/pycm/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
}
