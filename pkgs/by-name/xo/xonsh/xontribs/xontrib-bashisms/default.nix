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
  pname = "xontrib-bashisms";
  version = "0.0.5";

  src = fetchFromGitHub {
    owner = "xonsh";
    repo = "xontrib-bashisms";
    tag = version;
    hash = "sha256-R1DCGMrRCJLnz/QMk6QB8ai4nx88vvyPdaCKg3od5/I=";
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
    description = "Bash-like interactive mode extensions for the xonsh shell";
    homepage = "https://github.com/xonsh/xontrib-bashisms";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ greg ];
  };
}
