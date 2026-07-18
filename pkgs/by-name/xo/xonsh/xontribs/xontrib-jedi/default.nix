{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  jedi,
  nix-update-script,
  poetry-core,
  pytestCheckHook,
  writableTmpDirAsHomeHook,
  xonsh,
}:

buildPythonPackage rec {
  pname = "xontrib-jedi";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "xonsh";
    repo = "xontrib-jedi";
    tag = "v${version}";
    hash = "sha256-T4Yxr91emM2mjclQOjQsnnPO/JijAGNcqmZjxrz72Bs=";
  };

  nativeCheckInputs = [
    writableTmpDirAsHomeHook
    pytestCheckHook
    xonsh
  ];

  preCheck = ''
    substituteInPlace tests/test_jedi.py \
      --replace-fail "/usr/bin" "${jedi}/bin"
  '';

  build-system = [
    poetry-core
  ];

  dependencies = [
    jedi
  ];

  prePatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'xonsh = ">=0.17"' ""
  '';

  pyproject = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Xonsh Python mode completions using jedi";
    homepage = "https://github.com/xonsh/xontrib-jedi";
    changelog = "https://github.com/xonsh/xontrib-jedi/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ greg ];
  };
}
