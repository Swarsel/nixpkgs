{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  gettext,
  gtk3,
  ibus,
  m17n_db,
  m17n_lib,
  pkg-config,
  python3,
  wrapGAppsHook3,
}:

stdenv.mkDerivation rec {
  pname = "ibus-m17n";
  version = "1.4.37";

  src = fetchFromGitHub {
    owner = "ibus";
    repo = "ibus-m17n";
    rev = version;
    sha256 = "sha256-cJ5kRz1qu7lmCBjJBS8fBE5YdQMZiISWoK1a2KHZ4cQ=";
  };

  nativeBuildInputs = [
    autoreconfHook
    gettext
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    ibus
    gtk3
    m17n_lib
    m17n_db
    (python3.withPackages (ps: [
      ps.pygobject3
      (ps.toPythonModule ibus)
    ]))
  ];

  configureFlags = [
    "--with-gtk=3.0"
  ];

  meta = {
    description = "m17n engine for ibus";
    homepage = "https://github.com/ibus/ibus-m17n";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    isIbusEngine = true;
  };
}
