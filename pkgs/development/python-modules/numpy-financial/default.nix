{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  meson,
  meson-python,
  numpy,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "numpy-financial";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "numpy";
    repo = "numpy-financial";
    tag = "v${version}";
    hash = "sha256-6hSi5Y292Ikfb2m2SLvIHJS0nZcGKgGzvybgmpxReWI=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    meson
    meson-python
    setuptools
  ];

  dependencies = [ numpy ];
  pyproject = true;
  pythonImportsCheck = [ "numpy_financial" ];

  meta = {
    description = "Collection of elementary financial functions";
    homepage = "https://numpy.org/numpy-financial/";
    changelog = "https://github.com/numpy/numpy-financial/releases/tag/v${version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ flokli ];
  };
}
