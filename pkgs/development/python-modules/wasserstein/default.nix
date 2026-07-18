{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fetchpatch,
  llvmPackages,
  numpy,
  pytestCheckHook,
  wurlitzer,
}:

buildPythonPackage rec {
  pname = "wasserstein";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "pkomiske";
    repo = "Wasserstein";
    rev = "v${version}";
    hash = "sha256-s9en6XwvO/WPsF7/+SEmGePHZQgl7zLgu5sEn4nD9YE=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-jp5updB3E1MYgLhBJwmBMTwBiFXtABMwTxt0G6xhoyA=";
      url = "https://github.com/thaler-lab/Wasserstein/commit/8667d59dfdf89eabf01f3ae93b23a30a27c21c58.patch";
    })
  ];

  buildInputs = [ llvmPackages.openmp ];

  propagatedBuildInputs = [
    numpy
    wurlitzer
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  disabledTestPaths = [
    "wasserstein/tests/test_emd.py" # requires "ot"
    # cyclic dependency on energyflow
    "wasserstein/tests/test_externalemdhandler.py"
    "wasserstein/tests/test_pairwiseemd.py"
  ];

  enabledTestPaths = [ "wasserstein/tests" ];
  format = "setuptools";
  pythonImportsCheck = [ "wasserstein" ];

  meta = {
    description = "Python/C++ library for computing Wasserstein distances efficiently";
    homepage = "https://github.com/pkomiske/Wasserstein";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ veprbl ];
  };
}
