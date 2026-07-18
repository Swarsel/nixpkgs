{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  gobject-introspection,
  gtk-doc,
  json-glib,
  libxcb,
  pkg-config,
  which,
  xorgproto,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "i3ipc-glib";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "altdesktop";
    repo = "i3ipc-glib";
    tag = "v${finalAttrs.version}";
    hash = "sha256-F9Tiwc/gB7BFWr/qerS4n/+k/nUvJsH7Bp2zb1fe3wU=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    which
    pkg-config
    gtk-doc
    gobject-introspection
  ];

  buildInputs = [
    libxcb
    json-glib
    xorgproto
  ];

  preAutoreconf = ''
    gtkdocize
  '';

  meta = {
    description = "C interface library to i3wm";
    homepage = "https://github.com/altdesktop/i3ipc-glib";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ teto ];
    platforms = lib.platforms.linux;
  };
})
