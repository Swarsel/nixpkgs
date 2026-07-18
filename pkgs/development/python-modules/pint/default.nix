{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  flexcache,
  flexparser,
  hatch-vcs,
  # build-system
  hatchling,
  matplotlib,
  numpy,
  platformdirs,
  # tests
  pytestCheckHook,
  typing-extensions,
  uncertainties,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "pint";
  version = "0.25.2";

  src = fetchFromGitHub {
    owner = "hgrecco";
    repo = "pint";
    tag = version;
    hash = "sha256-Ushg7e920TTW7AYXg5C076Bl/yWPLO+H8I3Ytlc7OKc=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    matplotlib
    writableTmpDirAsHomeHook
  ];

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    flexcache
    flexparser
    platformdirs
    typing-extensions

    # Both uncertainties and numpy are not necessarily needed for every
    # function of pint, but needed for the pint-convert executable which we
    # necessarily distribute with this package as it is.
    uncertainties
    numpy
  ];

  disabledTestPaths = [
    "pint/testsuite/benchmarks"
  ];

  pyproject = true;

  meta = {
    description = "Physical quantities module";
    homepage = "https://github.com/hgrecco/pint/";
    changelog = "https://github.com/hgrecco/pint/blob/${version}/CHANGES";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ doronbehar ];
    mainProgram = "pint-convert";
  };
}
