{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  cython,
  fetchpatch2,
  # optional-dependencies
  matplotlib,
  meson-python,
  nibabel,
  ninja,
  # dependencies
  numpy,
  # tests
  pytestCheckHook,
  scipy,
  setuptools,
  sympy,
  transforms3d,
}:

buildPythonPackage rec {
  pname = "nipy";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "nipy";
    repo = "nipy";
    tag = version;
    hash = "sha256-KGMGu0/0n1CzN++ri3Ig1AJjeZfkl4KzNgm6jdwXB7o=";
  };

  patches = [
    # https://github.com/nipy/nipy/pull/589
    (fetchpatch2 {
      hash = "sha256-Rnwfx6JKl+nE9wvBGKXFtizjuB4Bl1QDF88CvSZU/RQ=";
      url = "https://github.com/nipy/nipy/pull/589/commits/76f2aae95dede9b8ac025dc32ce94791904f25e4.patch?full_index=1";
    })
  ];

  postPatch = ''
    patchShebangs nipy/_build_utils/cythoner.py
  '';

  doCheck = false; # partial imports … circular dependencies. needs more time to figure out.
  nativeCheckInputs = [ pytestCheckHook ] ++ optional-dependencies.optional;

  build-system = [
    cython
    meson-python
    setuptools
    ninja
    numpy
  ];

  dependencies = [
    nibabel
    numpy
    scipy
    sympy
    transforms3d
  ];

  optional-dependencies.optional = [ matplotlib ];
  pyproject = true;

  pythonImportsCheck = [
    "nipy"
    "nipy.testing"
    "nipy.algorithms"
  ];

  meta = {
    description = "Software for structural and functional neuroimaging analysis";
    homepage = "https://nipy.org/nipy";
    license = lib.licenses.bsd3;
    downloadPage = "https://github.com/nipy/nipy";
  };
}
