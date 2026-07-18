{
  lib,
  stdenv,
  fetchurl,
  buildPackages,
  gitUpdater,
  ncurses,
  # for tests
  python3Packages,
  readline,
  sqldiff,
  sqlite-analyzer,
  sqlite-rsync,
  tcl,
  tinysparql,
  unzip,
  zlib,
  # uses readline & ncurses for a better interactive experience if set to true
  interactive ? false,
}:

let
  archiveVersion = import ./archive-version.nix lib;
in

stdenv.mkDerivation rec {
  pname = "sqlite${lib.optionalString interactive "-interactive"}";
  version = "3.53.1";

  # nixpkgs-update: no auto update
  # NB! Make sure to update ./tools.nix src (in the same directory).
  src = fetchurl {
    url = "https://sqlite.org/2026/sqlite-src-${archiveVersion version}.zip";
    hash = "sha256-GytXVdkGTE1dGwv1MHtIsImWPikcQMxzUTGKobYcRg4=";
  };

  outputs = [
    "bin"
    "dev"
    "man"
    "doc"
    "out"
  ];

  nativeBuildInputs = [
    unzip
    tcl
  ];

  buildInputs = [
    zlib
  ]
  ++ lib.optionals interactive [
    readline
    ncurses
  ];

  configureFlags = [
    "--bindir=${placeholder "bin"}/bin"
    "--includedir=${placeholder "dev"}/include"
    "--libdir=${placeholder "out"}/lib"
    (if stdenv.hostPlatform.isStatic then "--disable-tcl" else "--with-tcl=${lib.getLib tcl}/lib")
    # Enabling limit-on-update/delete by adding -DSQLITE_ENABLE_UPDATE_DELETE_LIMIT to NIX_CFLAGS_COMPILE does not work: the lemon parser generator (built early in buildPhase) doesn't receive the flag when it's invoked, as it's not been wrapped with Nix magic.
    "--enable-update-limit"
  ]
  ++ lib.optional (!interactive) "--disable-readline"
  # autosetup only looks up readline.h in predefined set of directories.
  ++ lib.optional interactive "--with-readline-header=${lib.getDev readline}/include/readline/readline.h"
  ++ lib.optional (stdenv.hostPlatform.isStatic) "--disable-shared";

  env.NIX_CFLAGS_COMPILE = toString [
    "-DSQLITE_ENABLE_COLUMN_METADATA"
    "-DSQLITE_ENABLE_DBSTAT_VTAB"
    "-DSQLITE_ENABLE_JSON1"
    "-DSQLITE_ENABLE_FTS3"
    "-DSQLITE_ENABLE_FTS3_PARENTHESIS"
    "-DSQLITE_ENABLE_FTS3_TOKENIZER"
    "-DSQLITE_ENABLE_FTS4"
    "-DSQLITE_ENABLE_FTS5"
    "-DSQLITE_ENABLE_GEOPOLY"
    "-DSQLITE_ENABLE_MATH_FUNCTIONS"
    "-DSQLITE_ENABLE_PERCENTILE"
    "-DSQLITE_ENABLE_PREUPDATE_HOOK"
    "-DSQLITE_ENABLE_RBU"
    "-DSQLITE_ENABLE_RTREE"
    "-DSQLITE_ENABLE_SESSION"
    "-DSQLITE_ENABLE_STMT_SCANSTATUS"
    "-DSQLITE_ENABLE_UNLOCK_NOTIFY"
    "-DSQLITE_SOUNDEX"
    "-DSQLITE_SECURE_DELETE"
    "-DSQLITE_MAX_VARIABLE_NUMBER=250000"
    "-DSQLITE_MAX_EXPR_DEPTH=10000"
  ];

  env.TCLLIBDIR = "${placeholder "out"}/lib";

  # required for aarch64 but applied for all arches for simplicity
  preConfigure = ''
    patchShebangs configure
  '';

  # Test for features which may not be available at compile time
  preBuild = ''
    # Necessary for FTS5 on Linux
    export NIX_CFLAGS_LINK="$NIX_CFLAGS_LINK -lm"

    echo ""
    echo "NIX_CFLAGS_COMPILE = $NIX_CFLAGS_COMPILE"
    echo ""
  '';

  # SQLite’s tests are unreliable on Darwin. Sometimes they run successfully, but often they do not.
  # The tests are only defined for Darwin, Linux, Windows, and OpenBSD, not any other unix-like OS.
  doCheck = stdenv.hostPlatform.isLinux;

  postInstall = ''
    mkdir -p $doc/share/doc
    unzip $docsrc
    mv sqlite-doc-${archiveVersion version} $doc/share/doc/sqlite
  '';

  # When tcl is not available, only run test targets that don't need it.
  checkTarget = lib.optionalString stdenv.hostPlatform.isStatic "fuzztest sourcetest";

  depsBuildBuild = [
    buildPackages.stdenv.cc
  ];

  docsrc = fetchurl {
    hash = "sha256-n9Bgv33YwseOdBHQb7gdyKqgWeth7sgMZeBlioVFtDM=";
    url = "https://sqlite.org/2026/sqlite-doc-${archiveVersion version}.zip";
  };

  separateDebugInfo = stdenv.hostPlatform.isLinux;
  # sqlite relies on autosetup now; so many of the
  # previously-understood flags are gone. They should instead be set
  # on a per-output basis.
  setOutputFlags = false;

  passthru = {
    tests = {
      inherit (python3Packages) sqlalchemy;

      inherit
        sqldiff
        sqlite-analyzer
        sqlite-rsync
        tinysparql
        ;
    };

    updateScript = gitUpdater {
      # Expect tags like "version-3.43.0".
      rev-prefix = "version-";
      # No nicer place to look for latest version.
      url = "https://github.com/sqlite/sqlite.git";
    };
  };

  meta = {
    description = "Self-contained, serverless, zero-configuration, transactional SQL database engine";
    homepage = "https://www.sqlite.org/";
    changelog = "https://www.sqlite.org/releaselog/${lib.replaceStrings [ "." ] [ "_" ] version}.html";
    license = lib.licenses.publicDomain;
    maintainers = with lib.maintainers; [ np ];
    platforms = lib.platforms.unix ++ lib.platforms.windows;
    mainProgram = "sqlite3";
    downloadPage = "https://sqlite.org/download.html";
    identifiers.cpeParts = lib.meta.cpeFullVersionWithVendor "sqlite" version;
    pkgConfigModules = [ "sqlite3" ];
    teams = [ lib.teams.security-review ];
  };
}
