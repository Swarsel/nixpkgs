{
  lib,
  stdenv,
  buildPackages,
  buildPythonPackage,
  fetchPypi,
  isPyPy,
  libpq,
  openssl,
  postgresql,
  postgresqlTestHook,
  setuptools,
  sphinx-better-theme,
  sphinxHook,
}:

buildPythonPackage rec {
  pname = "psycopg2";
  version = "2.9.11";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-lk0xyvco4hfGl/936mnCughl+kHsILsA8Jd+Yv3MUuM=";
  };

  outputs = [
    "out"
    "doc"
  ];

  postPatch = ''
    # Preferably upstream would not depend on pg_config because config scripts are incompatible with cross-compilation, however postgresql's pc file is lacking information.
    # some linker flags are added but the linker ignores them because they're incompatible
    # https://github.com/psycopg/psycopg2/blob/89005ac5b849c6428c05660b23c5a266c96e677d/setup.py
    substituteInPlace setup.py \
      --replace-fail "self.pg_config_exe = self.build_ext.pg_config" 'self.pg_config_exe = "${libpq.pg_config}/bin/pg_config"'
  '';

  nativeBuildInputs = [
    sphinxHook
    sphinx-better-theme
  ];

  buildInputs = [ libpq ] ++ lib.optionals stdenv.hostPlatform.isDarwin [ openssl ];

  env = {
    PGDATABASE = "psycopg2_test";
  };

  # test suite breaks at some point with:
  #   current transaction is aborted, commands ignored until end of transaction block
  doCheck = false;

  nativeCheckInputs = [
    postgresql
    postgresqlTestHook
  ];

  build-system = [
    setuptools
  ];

  # Extension modules don't work well with PyPy. Use psycopg2cffi instead.
  # c.f. https://github.com/NixOS/nixpkgs/pull/104151#issuecomment-729750892
  disabled = isPyPy;

  disallowedReferences = lib.optionals (stdenv.buildPlatform != stdenv.hostPlatform) [
    buildPackages.libpq
  ];

  pyproject = true;
  pythonImportsCheck = [ "psycopg2" ];
  sphinxRoot = "doc/src";

  meta = {
    description = "PostgreSQL database adapter for the Python programming language";
    homepage = "https://www.psycopg.org";

    license = with lib.licenses; [
      lgpl3Plus
      zpl20
    ];

    maintainers = [ ];
  };
}
