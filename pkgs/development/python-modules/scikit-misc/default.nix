{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  gfortran,
  git,
  meson-python,
  numpy,
  pkg-config,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "scikit-misc";
  version = "0.5.2";

  src = fetchFromGitHub {
    owner = "has2k1";
    repo = "scikit-misc";
    tag = "v${version}";
    hash = "sha256-G0zK13upo0tPd8x87X8cTBKWK63E5JPmAr1IVEijtaw=";
  };

  postPatch = ''
    patchShebangs .

    # unbound numpy and disable coverage testing in pytest
    substituteInPlace pyproject.toml \
      --replace-fail 'numpy>=2.0' 'numpy' \
      --replace-fail 'addopts = "' '#addopts = "'

    # provide a version to use when git fails to get the tag
    [[ -f skmisc/_version.py ]] || \
      echo '__version__ = "${version}"' > skmisc/_version.py
  '';

  nativeBuildInputs = [
    gfortran
    git
    pkg-config
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  # can not run tests from source directory
  preCheck = ''
    cd "$(mktemp -d)"
  '';

  build-system = [
    cython
    meson-python
    numpy
    setuptools
  ];

  dependencies = [ numpy ];
  pyproject = true;

  pytestFlags = [
    "--pyargs"
    "skmisc"
  ];

  pythonImportsCheck = [ "skmisc" ];

  meta = {
    description = "Miscellaneous tools for scientific computing";
    homepage = "https://github.com/has2k1/scikit-misc";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ onny ];
  };
}
