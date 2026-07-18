{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  cython,
  # tests
  gstools,
  # dependencies
  numpy,
  pentapy,
  pytestCheckHook,
  scikit-learn,
  scipy,
  setuptools,
  setuptools-scm,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "pykrige";
  version = "1.7.3";

  src = fetchFromGitHub {
    owner = "GeoStat-Framework";
    repo = "PyKrige";
    tag = "v${version}";
    hash = "sha256-zdszmT1LEfYBWzd+m2nITtl0lZHyU0fzszYxANQS6yU=";
  };

  nativeCheckInputs = [
    gstools
    pytestCheckHook
    scikit-learn
    writableTmpDirAsHomeHook
  ];

  build-system = [
    cython
    numpy
    pentapy
    scipy
    setuptools
    setuptools-scm
  ];

  dependencies = [
    numpy
    scipy
  ];

  # Requires network access
  disabledTests = [
    "test_krige_classification_housing"
    "test_pseudo_2d"
    "test_pseudo_3d"
    "test_krige_housing"
  ];

  pyproject = true;

  meta = {
    description = "Kriging Toolkit for Python";
    homepage = "https://github.com/GeoStat-Framework/PyKrige";
    changelog = "https://github.com/GeoStat-Framework/PyKrige/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    teams = [ lib.teams.geospatial ];
  };
}
