{
  lib,
  stdenv,
  autoreconfHook,
  fetchFromGitea,
  guile,
  pkg-config,
  sqlite,
  texinfo,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "guile-sqlite3";
  version = "0.1.3";

  src = fetchFromGitea {
    owner = "guile-sqlite3";
    repo = "guile-sqlite3";
    rev = "v${finalAttrs.version}";
    hash = "sha256-C1a6lMK4O49043coh8EQkTWALrPolitig3eYf+l+HmM=";
    domain = "notabug.org";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    guile
    pkg-config
    texinfo
  ];

  buildInputs = [
    guile
    sqlite
  ];

  makeFlags = [ "GUILE_AUTO_COMPILE=0" ];
  doCheck = true;
  enableParallelBuilding = true;

  meta = {
    inherit (guile.meta) platforms;
    description = "Guile bindings for the SQLite3 database engine";
    homepage = "https://notabug.org/guile-sqlite3/guile-sqlite3";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
  };
})
