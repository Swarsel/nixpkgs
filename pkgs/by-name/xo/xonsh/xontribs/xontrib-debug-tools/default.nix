{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  nix-update-script,
  pytestCheckHook,
  setuptools,
  writableTmpDirAsHomeHook,
  xonsh,
}:

buildPythonPackage rec {
  pname = "xontrib-debug-tools";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "xonsh";
    repo = "xontrib-debug-tools";
    tag = version;
    hash = "sha256-Z8AXKk94NxmF5rO2OMZzNX0GIP/Vj+mOtYUaifRX1cw=";
  };

  nativeCheckInputs = [
    writableTmpDirAsHomeHook
    pytestCheckHook
    xonsh
  ];

  build-system = [
    setuptools
  ];

  prePatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail '"xonsh>=0.12.5"' ""
  '';

  pyproject = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Debug tools for xonsh shell";
    homepage = "https://github.com/xonsh/xontrib-debug-tools";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ greg ];
  };
}
