{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  jupyter-client,
  nix-update-script,
  poetry-core,
  pytestCheckHook,
  writableTmpDirAsHomeHook,
  xonsh,
}:

buildPythonPackage rec {
  pname = "xontrib-jupyter";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "xonsh";
    repo = "xontrib-jupyter";
    tag = "v${version}";
    hash = "sha256-gf+jyA2il7MD+Moez/zBYpf4EaPiNcgr5ZrJFK4uD2k=";
  };

  nativeCheckInputs = [
    writableTmpDirAsHomeHook
    pytestCheckHook
    xonsh
  ];

  build-system = [
    poetry-core
  ];

  dependencies = [
    jupyter-client
  ];

  prePatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'xonsh = ">=0.12"' ""

    substituteInPlace xonsh_jupyter/shell.py \
      --replace-fail 'xonsh.base_shell' 'xonsh.shells.base_shell'
  '';

  pyproject = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Xonsh jupyter kernel allows to run Xonsh shell code in Jupyter, JupyterLab, Euporia, etc";
    homepage = "https://github.com/xonsh/xontrib-jupyter";
    changelog = "https://github.com/xonsh/xontrib-jupyter/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ greg ];
  };
}
