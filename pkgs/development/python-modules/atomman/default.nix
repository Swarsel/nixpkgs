{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  cython,
  # dependencies
  datamodeldict,
  matplotlib,
  numericalunits,
  numpy,
  pandas,
  # tests
  phonopy,
  potentials,
  pytestCheckHook,
  requests,
  scipy,
  setuptools,
  toolz,
  xmltodict,
}:

buildPythonPackage (finalAttrs: {
  pname = "atomman";
  version = "1.5.2";

  src = fetchFromGitHub {
    owner = "usnistgov";
    repo = "atomman";
    tag = "v${finalAttrs.version}";
    hash = "sha256-UmvMYVM1YmLvSaVLzWHdxYpRU+Z3z65cy7mfmDZfDG0=";
  };

  nativeCheckInputs = [
    phonopy
    pytestCheckHook
  ];

  preCheck = ''
    # By default, pytestCheckHook imports atomman from the current directory
    # instead of from where `pip` installs it and fails due to missing Cython
    # modules. Fix this by removing atomman from the current directory.
    #
    rm -r atomman
  '';

  build-system = [
    cython
    numpy
    setuptools
  ];

  dependencies = [
    datamodeldict
    matplotlib
    numericalunits
    numpy
    pandas
    potentials
    requests
    scipy
    toolz
    xmltodict
  ];

  disabledTests = [
    # needs network access to download database files
    "test_unique_shifts_prototype"
  ];

  pyproject = true;
  pythonImportsCheck = [ "atomman" ];
  pythonRelaxDeps = [ "atomman" ];

  meta = {
    description = "Atomistic Manipulation Toolkit";
    homepage = "https://github.com/usnistgov/atomman/";
    changelog = "https://github.com/usnistgov/atomman/blob/${finalAttrs.src.tag}/UPDATES.rst";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
