{
  lib,
  stdenv,
  fetchFromGitHub,
  cjs,
  clutter-gst,
  clutter-gtk,
  glib,
  gobject-introspection,
  gtk3,
  gtksourceview4,
  libmusicbrainz,
  meson,
  nemo,
  ninja,
  pkg-config,
  webkitgtk_4_1,
  wrapGAppsHook3,
  xreader,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nemo-preview";
  version = "6.6.0";

  src = fetchFromGitHub {
    owner = "linuxmint";
    repo = "nemo-extensions";
    tag = finalAttrs.version;
    hash = "sha256-tXeMkaCYnWzg+6ng8Tyg4Ms1aUeE3xiEkQ3tKEX6Vv8=";
  };

  nativeBuildInputs = [
    wrapGAppsHook3
    gobject-introspection
    meson
    pkg-config
    glib
    ninja
  ];

  buildInputs = [
    gtk3
    cjs
    gtksourceview4
    libmusicbrainz
    webkitgtk_4_1
    clutter-gtk
    clutter-gst
    nemo
    xreader
  ];

  sourceRoot = "${finalAttrs.src.name}/nemo-preview";

  meta = {
    description = "Quick previewer for Nemo, the Cinnamon desktop file manager";
    homepage = "https://github.com/linuxmint/nemo-extensions/tree/master/nemo-preview";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.cinnamon ];
  };
})
