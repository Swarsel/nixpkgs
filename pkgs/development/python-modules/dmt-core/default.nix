{
  lib,
  buildPythonPackage,
  colormath,
  cycler,
  fetchPypi,
  h5py,
  joblib,
  more-itertools,
  numpy,
  pandas,
  pint,
  pyarrow,
  pytest,
  pyyaml,
  reprint,
  requests,
  scikit-rf,
  scipy,
  semver,
  setuptools,
  verilogae,
}:

buildPythonPackage rec {
  pname = "dmt-core";
  version = "2.1.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-489E+uNn4NgyCwxsUMEPH/1ZuM+5uNq4zx8F88rkHMU=";
    pname = "DMT_core";
  };

  nativeBuildInputs = [
    reprint
    verilogae
  ];

  preConfigure = ''
    export HOME=$(mktemp -d)
  '';

  build-system = [
    setuptools
  ];

  dependencies = [
    colormath
    cycler
    h5py
    joblib
    more-itertools
    pandas
    pint
    pyarrow
    pytest
    pyyaml
    requests
    scikit-rf
    scipy
    setuptools
    numpy
    semver
  ];

  pyproject = true;

  pythonImportsCheck = [
    "DMT.core"
    "reprint"
    "verilogae"
  ];

  meta = {
    description = "Tool to help modeling engineers extract model parameters, run circuit and TCAD simulations and automate infrastructure";
    homepage = "https://gitlab.com/dmt-development/dmt-core";
    changelog = "https://gitlab.com/dmt-development/dmt-core/-/blob/Version_${version}/CHANGELOG?ref_type=tags";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      jasonodoom
      jleightcap
    ];

    teams = with lib.teams; [ ngi ];
  };
}
