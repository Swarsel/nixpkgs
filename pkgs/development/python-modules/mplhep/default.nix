{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  hatch-vcs,
  hatchling,
  # tests
  hist,
  # dependencies
  matplotlib,
  mplhep-data,
  numpy,
  packaging,
  pytest-mock,
  pytest-mpl,
  pytestCheckHook,
  scipy,
  uhi,
  uproot,
}:

buildPythonPackage rec {
  pname = "mplhep";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "scikit-hep";
    repo = "mplhep";
    tag = "v${version}";
    hash = "sha256-Sx/VR573Vhxfv043mVdMpu/v6Ukv/JrVXBlpbILqGsI=";
  };

  nativeCheckInputs = [
    hist
    pytest-mock
    pytest-mpl
    pytestCheckHook
    scipy
    uproot
  ];

  build-system = [
    hatch-vcs
    hatchling
  ];

  dependencies = [
    matplotlib
    mplhep-data
    numpy
    packaging
    uhi
  ];

  disabledTestPaths = [
    # requires uproot4
    "tests/test_inputs.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "mplhep" ];

  meta = {
    description = "Extended histogram plots on top of matplotlib and HEP compatible styling similar to current collaboration requirements (ROOT)";
    homepage = "https://github.com/scikit-hep/mplhep";
    changelog = "https://github.com/scikit-hep/mplhep/releases/tag/${src.tag}";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ veprbl ];
  };
}
