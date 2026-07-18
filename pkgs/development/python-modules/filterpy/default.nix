{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  isPy3k,
  matplotlib,
  numpy,
  pytestCheckHook,
  scipy,
  setuptools,
}:

buildPythonPackage {
  pname = "filterpy";
  version = "1.4.5-unstable-2022-08-23";

  src = fetchFromGitHub {
    owner = "rlabbe";
    repo = "filterpy";
    rev = "3b51149ebcff0401ff1e10bf08ffca7b6bbc4a33";
    hash = "sha256-KuuVu0tqrmQuNKYmDmdy+TU6BnnhDxh4G8n9BGzjGag=";
  };

  patches = [ ./numpy-2.4-compat.patch ];
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    numpy
    scipy
    matplotlib
  ];

  disabled = !isPy3k;

  disabledTests = [
    # ValueError: Unable to avoid copy while creating an array as requested."
    "test_multivariate_gaussian"
  ];

  pyproject = true;

  meta = {
    description = "Kalman filtering and optimal estimation library";
    homepage = "https://github.com/rlabbe/filterpy";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
