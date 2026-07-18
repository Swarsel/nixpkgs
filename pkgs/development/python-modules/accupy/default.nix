{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  dufte,
  eigen,
  matplotlib,
  mpmath,
  numpy,
  perfplot,
  pybind11,
  pyfma,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "accupy";
  version = "0.3.6";

  src = fetchFromGitHub {
    owner = "nschloe";
    repo = "accupy";
    rev = version;
    hash = "sha256-xxwLmL/rFgDFQNr8mRBFG1/NArQk9wanelL4Lu7ls2s=";
  };

  buildInputs = [ eigen ];
  # This variable is needed to suppress the "Trace/BPT trap: 5" error in Darwin's checkPhase.
  # Not sure of the details, but we can avoid it by changing the matplotlib backend during testing.
  env.MPLBACKEND = lib.optionalString stdenv.hostPlatform.isDarwin "Agg";

  postConfigure = ''
    substituteInPlace setup.py \
      --replace-fail "/usr/include/eigen3/" "${eigen}/include/eigen3/"
  '';

  preBuild = ''
    export HOME=$(mktemp -d)
  '';

  nativeCheckInputs = [
    perfplot
    pytestCheckHook
    matplotlib
    dufte
  ];

  # performance tests aren't useful to us and disabling them allows us to
  # decouple ourselves from an unnecessary build dep
  preCheck = ''
    for f in test/test*.py ; do
      substituteInPlace $f --replace-quiet 'import perfplot' ""
    done
  '';

  build-system = [
    setuptools
    pybind11
  ];

  dependencies = [
    mpmath
    numpy
    pyfma
  ];

  disabledTests = [
    "test_speed_comparison1"
    "test_speed_comparison2"
  ];

  pyproject = true;
  pythonImportsCheck = [ "accupy" ];

  meta = {
    description = "Accurate sums and dot products for Python";
    homepage = "https://github.com/nschloe/accupy";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
