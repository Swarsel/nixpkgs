{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  # tests
  anyio,
  buildPythonPackage,
  # psycopg-c
  cython,
  # docs
  furo,
  # build
  libpq,
  postgresql,
  postgresqlTestHook,
  pproxy,
  pytestCheckHook,
  replaceVars,
  setuptools,
  shapely,
  sphinx-autodoc-typehints,
  sphinxHook,
  # propagates
  typing-extensions,
}:

let
  pname = "psycopg";
  version = "3.3.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "psycopg";
    repo = "psycopg";
    tag = version;
    hash = "sha256-hHgswbqaoQRQrUxhNFG6tfmlap1mVUo/OkNsWF686U4=";
  };

  patches = [
    (replaceVars ./ctypes.patch {
      libc = "${stdenv.cc.libc}/lib/libc.so.6";
      libpq = "${libpq}/lib/libpq${stdenv.hostPlatform.extensions.sharedLibrary}";
    })
  ];

  baseMeta = {
    changelog = "https://github.com/psycopg/psycopg/blob/${version}/docs/news.rst#current-release";
    homepage = "https://github.com/psycopg/psycopg";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ hexa ];
  };

  psycopg-c = buildPythonPackage {
    inherit version pyproject src;
    # apply patches to base repo
    inherit patches;
    pname = "${pname}-c";

    # move into source root after patching
    postPatch = ''
      cd psycopg_c

      substituteInPlace pyproject.toml \
        --replace-fail "setuptools ==" "setuptools >="
    '';

    nativeBuildInputs = [
      libpq.pg_config
    ];

    buildInputs = [
      libpq
    ];

    # tested in psycopg
    doCheck = false;

    build-system = [
      cython
      setuptools
    ];

    meta = baseMeta // {
      description = "C optimisation distribution for Psycopg";
    };
  };

  psycopg-pool = buildPythonPackage {
    inherit version pyproject src;
    # apply patches to base repo
    inherit patches;
    pname = "${pname}-pool";

    # move into source root after patching
    postPatch = ''
      cd psycopg_pool
    '';

    # tested in psycopg
    doCheck = false;
    build-system = [ setuptools ];
    dependencies = [ typing-extensions ];

    meta = baseMeta // {
      description = "Connection Pool for Psycopg";
    };
  };
in

buildPythonPackage rec {
  inherit
    pname
    version
    pyproject
    src
    ;

  inherit patches;

  outputs = [
    "out"
  ]
  ++ lib.optionals (stdenv.hostPlatform == stdenv.buildPlatform) [
    "doc"
  ];

  # only move to sourceRoot after patching, makes patching easier
  postPatch = ''
    cd psycopg
  '';

  # building the docs fails with the following error when cross compiling
  #  AttributeError: module 'psycopg_c.pq' has no attribute '__impl__'
  nativeBuildInputs = lib.optionals (stdenv.hostPlatform == stdenv.buildPlatform) [
    furo
    sphinx-autodoc-typehints
    sphinxHook
    shapely
  ];

  propagatedBuildInputs = [
    psycopg-c
    typing-extensions
  ];

  env = {
    # Introduce this file necessary for the docs build via environment var
    LIBPQ_DOCS_FILE = fetchurl {
      hash = "sha256-JwtCngkoi9pb0pqIdNgukY8GbG5pUDZvrGAHZqjFOw4";
      url = "https://raw.githubusercontent.com/postgres/postgres/496a1dc44bf1261053da9b3f7e430769754298b4/doc/src/sgml/libpq.sgml";
    };

    PGDATABASE = "psycopg";
    PGUSER = "psycopg";
    postgresqlEnableTCP = 1;
  };

  nativeCheckInputs = [
    anyio
    pproxy
    pytestCheckHook
    postgresql
  ]
  ++ lib.optional stdenv.hostPlatform.isLinux postgresqlTestHook
  ++ optional-dependencies.c
  ++ optional-dependencies.pool;

  preCheck = ''
    cd ..
  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    export PSYCOPG_TEST_DSN="host=/build/run/postgresql user=$PGUSER"
  '';

  postCheck = ''
    cd psycopg
  '';

  build-system = [ setuptools ];

  disabledTestMarks = [
    "refcount"
    "timing"
    "flakey"
    "slow"
  ];

  disabledTestPaths = [
    # Network access
    "tests/test_dns.py"
    "tests/test_dns_srv.py"
    # Mypy typing test
    "tests/test_typing.py"
    "tests/crdb/test_typing.py"
  ];

  disabledTests = [
    # don't depend on mypy for tests
    "test_version"
    "test_package_version"
    # expects timeout, but we have no route in the sandbox
    "test_connect_error_multi_hosts_each_message_preserved"
    # Flaky, fails intermittently
    "test_break_attempts"
    # ConnectionResetError: [Errno 104] Connection reset by peer
    "test_wait_r"
  ];

  optional-dependencies = {
    c = [ psycopg-c ];
    pool = [ psycopg-pool ];
  };

  pytestFlags = [
    "-ocache_dir=.cache"
  ];

  pythonImportsCheck = [
    "psycopg"
    "psycopg_c"
    "psycopg_pool"
  ];

  sphinxRoot = "../docs";

  passthru = {
    c = psycopg-c;
    pool = psycopg-pool;
  };

  meta = baseMeta // {
    description = "PostgreSQL database adapter for Python";
  };
}
