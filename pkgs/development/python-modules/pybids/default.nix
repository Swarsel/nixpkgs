{
  lib,
  fetchFromGitHub,
  bids-validator,
  buildPythonPackage,
  click,
  formulaic,
  frozendict,
  nibabel,
  num2words,
  numpy,
  pandas,
  pytestCheckHook,
  scipy,
  setuptools,
  sqlalchemy,
  universal-pathlib,
  versioneer,
}:

buildPythonPackage rec {
  pname = "pybids";
  version = "0.21.0";

  src = fetchFromGitHub {
    owner = "bids-standard";
    repo = "pybids";
    tag = version;
    hash = "sha256-yCfEE142OQCfgKVJB2lw1Rweax1gakHPoD91SUtZpUs=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'dynamic = ["version"]' 'version = "${version}"'
  '';

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    versioneer
  ];

  dependencies = [
    bids-validator
    click
    formulaic
    frozendict
    nibabel
    num2words
    numpy
    pandas
    scipy
    sqlalchemy
    universal-pathlib
  ];

  disabledTestPaths = [
    # Could not connect to the endpoint URL
    "src/bids/layout/tests/test_remote_bids.py"
  ];

  disabledTests = [
    # Regression associated with formulaic >= 0.6.0
    # (see https://github.com/bids-standard/pybids/issues/1000)
    "test_split"
  ];

  pyproject = true;
  pythonImportsCheck = [ "bids" ];

  pythonRelaxDeps = [
    "formulaic"
    "sqlalchemy"
  ];

  meta = {
    description = "Python tools for querying and manipulating BIDS datasets";
    homepage = "https://github.com/bids-standard/pybids";
    changelog = "https://github.com/bids-standard/pybids/blob/${version}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ wegank ];
    mainProgram = "pybids";
  };
}
