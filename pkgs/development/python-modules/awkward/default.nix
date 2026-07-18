{
  lib,
  fetchFromGitHub,
  # dependencies
  awkward-cpp,
  buildPythonPackage,
  fsspec,
  # build-system
  hatch-fancy-pypi-readme,
  hatchling,
  # tests
  numba,
  numexpr,
  numpy,
  packaging,
  pandas,
  pyarrow,
  pytest-xdist,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "awkward";
  version = "2.10.0";

  src = fetchFromGitHub {
    owner = "scikit-hep";
    repo = "awkward";
    tag = "v${finalAttrs.version}";
    hash = "sha256-yurwjlChMMLoGGMvoDA8O63jpnQepIi8KdG6U78+2y0=";
  };

  nativeCheckInputs = [
    fsspec
    numba
    numexpr
    pandas
    pyarrow
    pytest-xdist
    pytestCheckHook
  ];

  __structuredAttrs = true;

  build-system = [
    hatch-fancy-pypi-readme
    hatchling
  ];

  dependencies = [
    awkward-cpp
    fsspec
    numpy
    packaging
  ];

  disabledTestPaths = [
    # Need to be run on a GPU platform.
    "tests-cuda/*"
  ];

  dontUseCmakeConfigure = true;
  pyproject = true;
  pythonImportsCheck = [ "awkward" ];

  meta = {
    description = "Manipulate JSON-like data with NumPy-like idioms";
    homepage = "https://github.com/scikit-hep/awkward";
    changelog = "https://github.com/scikit-hep/awkward/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ veprbl ];
  };
})
