{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  chardet,
  # optionals
  faust-cchardet,
  packaging,
  pandas,
  pytestCheckHook,
  # TODO: , wilderness
  # tests
  python,
  regex,
  # build-system
  setuptools,
  tabview,
}:

buildPythonPackage rec {
  pname = "clevercsv";
  version = "0.8.5";

  src = fetchFromGitHub {
    owner = "alan-turing-institute";
    repo = "CleverCSV";
    tag = "v${version}";
    hash = "sha256-XbRydL/4EzsKKlxtMnuv5HLB0VAThRAjH0IDCfRFFTc=";
  };

  nativeCheckInputs = [ pytestCheckHook ] ++ optional-dependencies.full;

  preCheck = ''
    # by linking the installed version the tests also have access to compiled native libraries
    rm -r clevercsv
    ln -s $out/${python.sitePackages}/clevercsv/ clevercsv
  '';

  build-system = [ setuptools ];

  dependencies = [
    chardet
    regex
    packaging
  ];

  disabledTestPaths = [
    # ModuleNotFoundError: No module named 'wilderness'
    "tests/test_unit/test_console.py"
  ];

  # their ci only runs unit tests, there are also integration and fuzzing tests
  enabledTestPaths = [ "./tests/test_unit" ];

  optional-dependencies = {
    full = [
      faust-cchardet
      pandas
      tabview
      # TODO: wilderness
    ];
  };

  pyproject = true;

  pythonImportsCheck = [
    "clevercsv"
    "clevercsv.cparser"
  ];

  meta = {
    description = "Python package for handling messy CSV files";

    longDescription = ''
      CleverCSV is a Python package for handling messy CSV files. It provides
      a drop-in replacement for the builtin CSV module with improved dialect
      detection, and comes with a handy command line application for working
      with CSV files.
    '';

    homepage = "https://github.com/alan-turing-institute/CleverCSV";
    changelog = "https://github.com/alan-turing-institute/CleverCSV/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
    mainProgram = "clevercsv";
  };
}
