{
  lib,
  stdenv,
  fetchFromGitHub,
  antlr4,
  antlr4-python3-runtime,
  asciimatics,
  buildPythonPackage,
  click,
  dacite,
  decorator,
  first,
  jsonpath-ng,
  loguru,
  overrides,
  parameterized,
  pillow,
  ply,
  pyfiglet,
  pyperclip,
  pytestCheckHook,
  pyyaml,
  setuptools,
  urwid,
  wcwidth,
  yamale,
}:

buildPythonPackage rec {
  pname = "python-fx";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "cielong";
    repo = "pyfx";
    tag = "v${version}";
    hash = "sha256-Q5ihWnoa7nf4EkrY4SgrwjaNvTva4RdW9GRbnbsPXPc=";
  };

  postPatch = ''
    rm src/pyfx/model/common/jsonpath/*.py # upstream checks in generated files, remove to ensure they were regenerated
    antlr -Dlanguage=Python3 -visitor src/pyfx/model/common/jsonpath/*.g4
    rm src/pyfx/model/common/jsonpath/*.{g4,interp,tokens} # no need to install

    # https://github.com/cielong/pyfx/pull/148
    substituteInPlace src/pyfx/view/common/frame.py \
      --replace-fail "self.__super.__init__()" "super().__init__()"
  '';

  nativeBuildInputs = [ antlr4 ];
  # FAILED tests/test_event_loops.py::TwistedEventLoopTest::test_run - AssertionError: 'callback called with future outcome: True' not found in ['...
  doCheck = !stdenv.hostPlatform.isDarwin;

  nativeCheckInputs = [
    pytestCheckHook
    parameterized
  ];

  build-system = [ setuptools ];

  dependencies = [
    antlr4-python3-runtime
    asciimatics
    click
    dacite
    decorator
    first
    jsonpath-ng
    loguru
    overrides
    pillow
    ply
    pyfiglet
    pyperclip
    pyyaml
    urwid
    wcwidth
    yamale
  ];

  disabledTests = [
    # TypeError: CliRunner.__init__() got an unexpected keyword argument 'mix_stderr'
    "test_start"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyfx" ];
  pythonRelaxDeps = true;

  meta = {
    description = "Module to view JSON in a TUI";
    homepage = "https://github.com/cielong/pyfx";
    changelog = "https://github.com/cielong/pyfx/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "pyfx";
  };
}
