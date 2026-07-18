{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "hpp2plantuml";
  version = "0.8.6";

  src = fetchFromGitHub {
    owner = "thibaultmarin";
    repo = "hpp2plantuml";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8OmZfXPkRO8lgxTH6eedaiYLn0HGf+T7L+AxoA2amkQ=";
  };

  buildInputs = with python3Packages; [
    sphinx
    numpydoc
  ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    jinja2
    cppheaderparser
  ];

  # These tests fail because upstream expects robotpy-cppheaderparser (a fork)
  # but we use the original cppheaderparser which has slightly different
  # behaviour (template formatting and parent field type differences).
  disabledTests = [
    "test_list_entries"
    "test_full_files"
    "test_main_function"
  ];

  pyproject = true;
  pythonImportsCheck = [ "hpp2plantuml" ];

  # argparse is part of the Python standard library since Python 3.2;
  # the PyPI package is only a backport for older Python versions.
  # robotpy-cppheaderparser is deprecated and not packaged in nixpkgs;
  # we use the original cppheaderparser instead which provides the same
  # CppHeaderParser Python module but has known incompatibilities (nested classes, template formatting)
  # causing some functionality to break — see disabledTests below.
  pythonRemoveDeps = [
    "argparse"
    "robotpy-cppheaderparser"
  ];

  meta = {
    description = "Convert C++ header files to PlantUML";
    homepage = "https://github.com/thibaultmarin/hpp2plantuml";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ eymeric ];
    mainProgram = "hpp2plantuml";
  };
})
