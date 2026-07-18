{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  darwin,
  pexpect,
  poetry,
  poetry-core,
  pytest-mock,
  pytest-xdist,
  pytestCheckHook,
  shellingham,
}:

buildPythonPackage rec {
  pname = "poetry-plugin-shell";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "python-poetry";
    repo = "poetry-plugin-shell";
    tag = version;
    hash = "sha256-BntObwrW7xt1gYWpckLJF7GklkmUJMh8D1IUwCcOOl4=";
  };

  buildInputs = [
    poetry
  ];

  nativeCheckInputs = [
    pytest-mock
    pytest-xdist
    pytestCheckHook
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    darwin.ps
  ];

  build-system = [ poetry-core ];

  dependencies = [
    pexpect
    shellingham
  ];

  pyproject = true;

  meta = {
    description = "Poetry plugin to run subshell with virtual environment activated";
    homepage = "https://github.com/python-poetry/poetry-plugin-shell";
    changelog = "https://github.com/python-poetry/poetry-plugin-shell/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
