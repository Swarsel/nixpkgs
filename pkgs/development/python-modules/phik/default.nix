{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cmake,
  joblib,
  matplotlib,
  ninja,
  numpy,
  pandas,
  pathspec,
  pybind11,
  pyproject-metadata,
  pytestCheckHook,
  scikit-build-core,
  scipy,
}:

buildPythonPackage rec {
  pname = "phik";
  version = "0.12.5";

  src = fetchFromGitHub {
    owner = "KaveIO";
    repo = "PhiK";
    tag = "v${version}";
    hash = "sha256-/Zzin3IHwlFEDQwKjzTwY4ET2r0k3Ne/2lGzXkur9p8=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    # import from $out
    rm -r phik
  '';

  build-system = [
    cmake
    ninja
    pathspec
    pybind11
    pyproject-metadata
    scikit-build-core
  ];

  dependencies = [
    joblib
    matplotlib
    numpy
    pandas
    scipy
  ];

  disabledTests = [
    # AssertionError: np.False_ is not true
    "test_phik_calculation"
  ];

  # Uses scikit-build-core to drive build process
  dontUseCmakeConfigure = true;
  pyproject = true;
  pythonImportsCheck = [ "phik" ];

  meta = {
    description = "Phi_K correlation analyzer library";

    longDescription = ''
      Phi_K is a new and practical correlation coefficient based on several refinements to
      Pearson’s hypothesis test of independence of two variables.
    '';

    homepage = "https://phik.readthedocs.io/";
    changelog = "https://github.com/KaveIO/PhiK/blob/${src.tag}/CHANGES.rst";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ melsigl ];
  };
}
