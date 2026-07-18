{
  lib,
  stdenv,
  fetchurl,
  adwaita-icon-theme,
  desktop-file-utils,
  fetchpatch,
  gdk-pixbuf,
  gnome,
  gsound,
  gtk3,
  itstool,
  librsvg,
  libxml2,
  meson,
  ninja,
  pkg-config,
  python3,
  vala,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "iagno";
  version = "3.38.1";

  src = fetchurl {
    url = "mirror://gnome/sources/iagno/${lib.versions.majorMinor finalAttrs.version}/iagno-${finalAttrs.version}.tar.xz";
    hash = "sha256-hLnzLOA4l1iiHWPH6xwifbcRa1HTFJqg6uNQkWjg7SQ=";
  };

  patches = [
    # Fix build with recent Vala.
    # https://gitlab.gnome.org/GNOME/dconf-editor/-/merge_requests/15
    (fetchpatch {
      hash = "sha256-OO1x0Yx56UFzHTBsPAMYAjnJHlnTjdO1Vk7q6XU8wKQ=";
      url = "https://gitlab.gnome.org/GNOME/iagno/-/commit/e8a0aeec350ea80349582142c0e8e3cd3f1bce38.patch";
    })
    # https://gitlab.gnome.org/GNOME/dconf-editor/-/merge_requests/13
    (fetchpatch {
      hash = "sha256-U7djuMhb1XJaKAPyogQjaunOkbBK24r25YD7BgH05P4=";
      url = "https://gitlab.gnome.org/GNOME/iagno/-/commit/508c0f94e5f182e50ff61be6e04f72574dee97cb.patch";
    })
  ];

  nativeBuildInputs = [
    meson
    ninja
    python3
    vala
    desktop-file-utils
    pkg-config
    wrapGAppsHook3
    itstool
    libxml2
  ];

  buildInputs = [
    gtk3
    adwaita-icon-theme
    gdk-pixbuf
    librsvg
    gsound
  ];

  passthru = {
    updateScript = gnome.updateScript { packageName = "iagno"; };
  };

  meta = {
    description = "Computer version of the game Reversi, more popularly called Othello";
    homepage = "https://gitlab.gnome.org/GNOME/iagno";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.unix;
    mainProgram = "iagno";
    teams = [ lib.teams.gnome ];
  };
})
