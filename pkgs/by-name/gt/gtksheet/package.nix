{
  lib,
  stdenv,
  fetchFromGitHub,
  atk,
  autoreconfHook,
  cairo,
  glade,
  gobject-introspection,
  gtk-doc,
  gtk3,
  pango,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gtksheet";
  version = "4.3.14";

  src = fetchFromGitHub {
    owner = "fpaquet";
    repo = "gtksheet";
    rev = "V${finalAttrs.version}";
    hash = "sha256-dpo4e/68PLbqUFoKiwlDUUIEFPRqT/5TBZzl7pfY+1Y=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    gobject-introspection
    gtk-doc
    pkg-config
  ];

  buildInputs = [
    atk
    cairo
    glade
    gtk3
    pango
  ];

  env.NIX_CFLAGS_COMPILE = "-Wno-error=incompatible-pointer-types";

  meta = {
    description = "Spreadsheet widget for GTK+";
    homepage = "https://fpaquet.github.io/gtksheet/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ wegank ];
    platforms = lib.platforms.unix;
  };
})
