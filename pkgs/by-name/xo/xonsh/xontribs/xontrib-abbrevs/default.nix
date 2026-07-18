{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  nix-update-script,
  poetry-core,
  prompt-toolkit,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
  writableTmpDirAsHomeHook,
  xonsh,
}:

buildPythonPackage rec {
  pname = "xontrib-abbrevs";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "xonsh";
    repo = "xontrib-abbrevs";
    tag = "v${version}";
    hash = "sha256-JxH5b2ey99tvHXSUreU5r6fS8nko4RrS/1c8psNbJNc=";
  };

  nativeCheckInputs = [
    writableTmpDirAsHomeHook
    pytestCheckHook
    xonsh
  ];

  build-system = [
    setuptools
    setuptools-scm
    poetry-core
  ];

  dependencies = [
    prompt-toolkit
  ];

  prePatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail '"xonsh>=0.17", ' ""
  '';

  pyproject = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Command abbreviations for Xonsh";
    homepage = "https://github.com/xonsh/xontrib-abbrevs";
    changelog = "https://github.com/xonsh/xontrib-apprevs/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ greg ];
  };
}
