{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  nix-update-script,
  pytest-subprocess,
  pytestCheckHook,
  setuptools,
  virtualenv,
  writableTmpDirAsHomeHook,
  xonsh,
}:

buildPythonPackage rec {
  pname = "xontrib-vox";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "xonsh";
    repo = "xontrib-vox";
    tag = version;
    hash = "sha256-OB1O5GZYkg7Ucaqak3MncnQWXhMD4BM4wXsYCDD0mhk=";
  };

  nativeCheckInputs = [
    writableTmpDirAsHomeHook
    pytestCheckHook
    pytest-subprocess
    xonsh
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    virtualenv
  ];

  disabledTests = [
    # Monkeypatch in test fails, preventing test from running
    "test_interpreter"
  ];

  prePatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail '"xonsh>=0.12.5"' ""
  '';

  pyproject = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Python virtual environment manager for the xonsh shell";
    homepage = "https://github.com/xonsh/xontrib-vox";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ greg ];
  };
}
