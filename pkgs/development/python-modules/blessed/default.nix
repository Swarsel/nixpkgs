{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  glibcLocales,
  mock,
  pytestCheckHook,
  six,
  wcwidth,
}:

buildPythonPackage {
  pname = "blessed";
  # We need https://github.com/jquast/blessed/pull/311 to fix 3.13
  version = "1.25-unstable-2025-12-05";

  src = fetchFromGitHub {
    owner = "jquast";
    repo = "blessed";
    rev = "cee680ff7fb3ad31f42ae98582ba74629f1fd6b0";
    hash = "sha256-4K1W0LXJKkb2wKE6D+IkX3oI5KxkpKbO661W/VTHgts=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    mock
    glibcLocales
  ];

  # Default tox.ini parameters not needed
  preCheck = ''
    rm tox.ini
  '';

  build-system = [ flit-core ];

  dependencies = [
    wcwidth
    six
  ];

  disabledTestPaths = lib.optionals stdenv.hostPlatform.isDarwin [
    # Fail with several AssertionError
    "tests/test_sixel.py"
  ];

  pyproject = true;

  meta = {
    description = "Thin, practical wrapper around terminal capabilities in Python";
    homepage = "https://github.com/jquast/blessed";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ eqyiel ];
  };
}
