{
  lib,
  buildPythonPackage,
  cython,
  distro,
  fetchPypi,
  libpq,
  postgresql,
  pytest-xdist,
  pytest8_3CheckHook,
  setuptools,
  uvloop,
}:

buildPythonPackage rec {
  pname = "asyncpg";
  version = "0.31.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-yYk4bIOUC/vXhxgPKxUZQV4tPWJ3pw2dDwFFrHNQBzU=";
  };

  # sandboxing issues on aarch64-darwin, see https://github.com/NixOS/nixpkgs/issues/198495
  doCheck = postgresql.doInstallCheck;

  nativeCheckInputs = [
    libpq.pg_config
    uvloop
    postgresql
    postgresql.pg_config
    pytest-xdist
    pytest8_3CheckHook
    distro
  ];

  preCheck = ''
    rm -rf asyncpg/

    export PGBIN=${lib.getBin postgresql}/bin
  '';

  build-system = [
    cython
    setuptools
  ];

  # https://github.com/MagicStack/asyncpg/issues/1236
  disabledTests = [ "test_connect_params" ];
  pyproject = true;
  pythonImportsCheck = [ "asyncpg" ];

  meta = {
    description = "Asyncio PosgtreSQL driver";

    longDescription = ''
      Asyncpg is a database interface library designed specifically for
      PostgreSQL and Python/asyncio. asyncpg is an efficient, clean
      implementation of PostgreSQL server binary protocol for use with Python's
      asyncio framework.
    '';

    homepage = "https://github.com/MagicStack/asyncpg";
    changelog = "https://github.com/MagicStack/asyncpg/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ eadwu ];
  };
}
