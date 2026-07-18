{
  lib,
  stdenv,
  ansitable,
  buildPythonPackage,
  fetchPypi,
  matplotlib,
  numpy,
  oldest-supported-numpy,
  pytestCheckHook,
  scipy,
  setuptools,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "spatialmath-python";
  version = "1.1.16";

  src = fetchPypi {
    inherit version;
    hash = "sha256-6y8EOxxXuqsDTAHW0wKOq4D17GjqouyJy5VyEHwzaiI=";
    pname = "spatialmath_python";
  };

  env.MPLBACKEND = lib.optionalString stdenv.hostPlatform.isDarwin "Agg";
  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    oldest-supported-numpy
    setuptools
  ];

  dependencies = [
    ansitable
    matplotlib
    numpy
    scipy
    typing-extensions
  ];

  disabledTestPaths = [
    # tests hang
    "tests/test_spline.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "spatialmath" ];
  pythonRelaxDeps = [ "matplotlib" ];
  pythonRemoveDeps = [ "pre-commit" ];

  meta = {
    description = "Provides spatial maths capability for Python";
    homepage = "https://pypi.org/project/spatialmath-python/";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      djacu
      a-camarillo
    ];
  };
}
