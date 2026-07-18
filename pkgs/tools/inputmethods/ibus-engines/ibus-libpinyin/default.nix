{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  db,
  gettext,
  glib,
  gobject-introspection,
  gtk3,
  ibus,
  json-glib,
  libnotify,
  libpinyin,
  libsoup_3,
  lua,
  opencc,
  pkg-config,
  python3,
  sqlite,
  wrapGAppsHook3,
}:

stdenv.mkDerivation rec {
  pname = "ibus-libpinyin";
  version = "1.16.5";

  src = fetchFromGitHub {
    owner = "libpinyin";
    repo = "ibus-libpinyin";
    tag = version;
    hash = "sha256-3QZHovjzGifWLFVudCnJOwMn/M3Nzfn8CZ1HpQwzUVw=";
  };

  nativeBuildInputs = [
    autoreconfHook
    gettext
    gobject-introspection.setupHook
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    ibus
    glib
    sqlite
    libpinyin
    (python3.withPackages (
      pypkgs: with pypkgs; [
        pygobject3
        (toPythonModule ibus)
      ]
    ))
    gtk3
    db
    lua
    opencc
    libsoup_3
    json-glib
    libnotify
  ];

  configureFlags = [
    "--enable-cloud-input-mode"
    "--enable-opencc"
  ];

  meta = {
    description = "IBus interface to the libpinyin input method";
    homepage = "https://github.com/libpinyin/ibus-libpinyin";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      linsui
    ];

    platforms = lib.platforms.linux;
    isIbusEngine = true;
  };
}
