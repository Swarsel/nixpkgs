{
  lib,
  fetchFromGitHub,
  # tests
  build,
  buildPythonPackage,
  # dependencies
  flit-core,
  # build-system
  flit-scm,
  gettext,
  pytest-cov-stub,
  pytestCheckHook,
  replaceVars,
  wheel,
}:

buildPythonPackage rec {
  pname = "flit-gettext";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "codingjoe";
    repo = "flit-gettext";
    rev = version;
    hash = "sha256-rCIMwAiXXCJ+PH26/hoPWsuKd68crWStBErAOh9wzUg=";
  };

  patches = [
    (replaceVars ./msgfmt-path.patch {
      msgfmt = lib.getExe' gettext "msgfmt";
    })
  ];

  nativeBuildInputs = [
    flit-scm
    wheel
  ];

  propagatedBuildInputs = [ flit-core ];

  nativeCheckInputs = [
    build
    pytestCheckHook
    pytest-cov-stub
    wheel
  ]
  ++ optional-dependencies.scm;

  disabledTestPaths = [
    # calls python -m build, but can't find build
    "tests/test_core.py"
    "tests/test_scm.py"
  ];

  disabledTests = [
    # tests for missing msgfmt, but we always provide it
    "test_compile_gettext_translations__no_gettext"
  ];

  optional-dependencies = {
    scm = [ flit-scm ];
  };

  pyproject = true;
  pythonImportsCheck = [ "flit_gettext" ];

  meta = {
    description = "Compiling gettext i18n messages during project bundling";
    homepage = "https://github.com/codingjoe/flit-gettext";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
