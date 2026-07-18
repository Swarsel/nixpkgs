{
  lib,
  stdenv,
  fetchFromGitHub,
  appstream-glib,
  autoreconfHook,
  gettext,
  gobject-introspection,
  gtk3,
  ibus,
  libhangul,
  pkg-config,
  python3,
  replaceVars,
  wrapGAppsHook3,
}:

stdenv.mkDerivation rec {
  pname = "ibus-hangul";
  version = "1.5.5";

  src = fetchFromGitHub {
    owner = "libhangul";
    repo = "ibus-hangul";
    rev = version;
    hash = "sha256-x2oOW8eiEuwmdCGUo+r/KcsitfGccSyianwIEaOBS3M=";
  };

  patches = [
    (replaceVars ./fix-paths.patch {
      libhangul = "${libhangul}/lib/libhangul.so.1";
    })
  ];

  nativeBuildInputs = [
    appstream-glib
    gettext
    pkg-config
    wrapGAppsHook3
    gobject-introspection.setupHook
    autoreconfHook
  ];

  buildInputs = [
    gtk3
    ibus
    libhangul
    (python3.withPackages (
      pypkgs: with pypkgs; [
        pygobject3
        (toPythonModule ibus)
      ]
    ))
  ];

  meta = {
    description = "Ibus Hangul engine";
    homepage = "https://github.com/libhangul/ibus-hangul";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "ibus-setup-hangul";
    isIbusEngine = true;
  };
}
