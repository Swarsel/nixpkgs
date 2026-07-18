{
  lib,
  stdenv,
  fetchurl,
  gettext,
  gnome,
  gtk3,
  itstool,
  libgnome-games-support,
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
  pname = "five-or-more";
  version = "48.1";

  src = fetchurl {
    url = "mirror://gnome/sources/five-or-more/${lib.versions.major finalAttrs.version}/five-or-more-${finalAttrs.version}.tar.xz";
    hash = "sha256-2UHOLjfqZsDYDx6BeX+8u+To72WnkLPMXla58QtepaM=";
  };

  postPatch = ''
    chmod +x meson_post_install.py # patchShebangs requires executable file
    patchShebangs meson_post_install.py
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gettext
    itstool
    libxml2
    python3
    wrapGAppsHook3
    vala
  ];

  buildInputs = [
    gtk3
    librsvg
    libgnome-games-support
  ];

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "five-or-more";
    };
  };

  meta = {
    description = "Remove colored balls from the board by forming lines";
    homepage = "https://gitlab.gnome.org/GNOME/five-or-more";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.unix;
    mainProgram = "five-or-more";
    teams = [ lib.teams.gnome ];
  };
})
