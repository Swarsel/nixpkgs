{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  libiodbc,
  libpq,
  nix-update-script,
  openssl,
  unixodbc,
  withLibiodbc ? false,
  withUnixODBC ? true,
}:

assert lib.xor withLibiodbc withUnixODBC;

stdenv.mkDerivation (finalAttrs: {
  pname = "psqlodbc";
  version = "18.00.0001";

  src = fetchFromGitHub {
    owner = "postgresql-interfaces";
    repo = "psqlodbc";
    tag = "REL-${lib.replaceString "." "_" finalAttrs.version}";
    hash = "sha256-gCacZjP0FkCEuZRBfawZ2B3BcjR/sV1fypuT8XD2l+A=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    libpq
    openssl
  ]
  ++ lib.optional withLibiodbc libiodbc
  ++ lib.optional withUnixODBC unixodbc;

  configureFlags = [
    "CPPFLAGS=-DSQLCOLATTRIBUTE_SQLLEN" # needed for cross
    "--with-libpq=${lib.getDev libpq}"
  ]
  ++ lib.optional withLibiodbc "--with-iodbc=${libiodbc}"
  ++ lib.optional withUnixODBC "--with-unixodbc=${unixodbc}";

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [ "--version-regex=^REL-(\\d+)_(\\d+)_(\\d+)$" ];
    };
  }
  // lib.optionalAttrs withUnixODBC {
    driver = "lib/psqlodbcw.so";
    fancyName = "PostgreSQL";
  };

  meta = {
    description = "ODBC driver for PostgreSQL";
    homepage = "https://odbc.postgresql.org/";
    license = lib.licenses.lgpl2;
    platforms = lib.platforms.unix;
    teams = libpq.meta.teams;
  };
})
