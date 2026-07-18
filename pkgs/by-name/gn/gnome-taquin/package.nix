{
  lib,
  stdenv,
  fetchurl,
  adwaita-icon-theme,
  desktop-file-utils,
  fetchpatch,
  gettext,
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
  pname = "gnome-taquin";
  version = "3.38.1";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-taquin/${lib.versions.majorMinor finalAttrs.version}/gnome-taquin-${finalAttrs.version}.tar.xz";
    hash = "sha256-lts9j61JeSSnOQrRCKPvckMqHWLSRWyuXhk0BXAYgU8=";
  };

  patches = [
    # Fix build with recent Vala.
    (fetchpatch {
      hash = "sha256-U7djuMhb1XJaKAPyogQjaunOkbBK24r25YD7BgH05P4=";
      url = "https://gitlab.gnome.org/GNOME/gnome-taquin/-/commit/99dea5e7863e112f33f16e59898c56a4f1a547b3.patch";
    })
    (fetchpatch {
      hash = "sha256-RN41RCLHlJyXTARSH9qjsmpYi1UFeMRssoYxRsbngDQ=";
      url = "https://gitlab.gnome.org/GNOME/gnome-taquin/-/commit/66be44dc20d114e449fc33156e3939fd05dfbb16.patch";
    })
  ];

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook3
    meson
    ninja
    python3
    gettext
    itstool
    libxml2
    vala
    desktop-file-utils
  ];

  buildInputs = [
    gtk3
    librsvg
    gsound
    adwaita-icon-theme
  ];

  passthru = {
    updateScript = gnome.updateScript { packageName = "gnome-taquin"; };
  };

  meta = {
    description = "Move tiles so that they reach their places";
    homepage = "https://gitlab.gnome.org/GNOME/gnome-taquin";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.unix;
    mainProgram = "gnome-taquin";
    teams = [ lib.teams.gnome ];
  };
})
