{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  distributed,
  nix-update-script,
  poetry-core,
  pytestCheckHook,
  writableTmpDirAsHomeHook,
  xonsh,
}:

buildPythonPackage rec {
  pname = "xontrib-distributed";
  version = "0.0.4";

  src = fetchFromGitHub {
    owner = "xonsh";
    repo = "xontrib-distributed";
    tag = "v${version}";
    hash = "sha256-Hb7S3PqHi0w6zb9ki8ADMtgdYVv8O5WQZMgJzKF74qE=";
  };

  # As of v0.0.4 has no tests that get run by pytest
  doCheck = false;

  nativeCheckInputs = [
    writableTmpDirAsHomeHook
    pytestCheckHook
    xonsh
  ];

  build-system = [
    poetry-core
  ];

  dependencies = [
    distributed
  ];

  prePatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'xonsh = ">=0.12"' ""
  '';

  pyproject = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Dask Distributed integration for Xonsh";
    homepage = "https://github.com/xonsh/xontrib-distributed";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ greg ];
  };
}
