{
  lib,
  stdenv,
  fetchurl,
  cmake,
  docutils,
  libbsd,
  libpq,
  ncurses,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pg_top";
  version = "4.1.3";

  src = fetchurl {
    url = "https://pg_top.gitlab.io/source/pg_top-${finalAttrs.version}.tar.xz";
    sha256 = "sha256-4El3GmfP5UDJOsDxyU5z/s3JKw0jlMb8EB/hvtywwVs=";
  };

  nativeBuildInputs = [
    cmake
    docutils
  ];

  buildInputs = [
    libbsd
    libpq
    ncurses
  ];

  meta = {
    description = "'top' like tool for PostgreSQL";

    longDescription = ''
      pg_top allows you to:
       * View currently running SQL statement of a process.
       * View query plan of a currently running SELECT statement.
       * View locks held by a process.
       * View I/O statistics per process.
       * View replication statistics for downstream nodes.
    '';

    homepage = "https://pg_top.gitlab.io";
    changelog = "https://gitlab.com/pg_top/pg_top/-/blob/main/HISTORY.rst";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
    mainProgram = "pg_top";
  };
})
