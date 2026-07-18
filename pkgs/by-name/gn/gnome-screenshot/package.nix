{
  lib,
  stdenv,
  fetchurl,
  adwaita-icon-theme,
  appstream-glib,
  desktop-file-utils,
  fetchpatch,
  gettext,
  glib,
  gnome,
  gsettings-desktop-schemas,
  gtk3,
  libcanberra-gtk3,
  libhandy,
  libxml2,
  meson,
  ninja,
  pkg-config,
  python3,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-screenshot";
  version = "41.0";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-screenshot/${lib.versions.major finalAttrs.version}/gnome-screenshot-${finalAttrs.version}.tar.xz";
    hash = "sha256-Stt97JJkKPdCY9V5ZnPPFC5HILbnaPVGio0JM/mMlZc=";
  };

  patches = [
    # Fix build with meson 0.61
    # https://gitlab.gnome.org/GNOME/gnome-screenshot/-/issues/186
    (fetchpatch {
      hash = "sha256-Js83h/3xxcw2hsgjzGa5lAYFXVrt6MPhXOTh5dZTx/w=";
      url = "https://gitlab.gnome.org/GNOME/gnome-screenshot/-/commit/b60dad3c2536c17bd201f74ad8e40eb74385ed9f.patch";
    })
  ];

  postPatch = ''
    chmod +x build-aux/postinstall.py # patchShebangs requires executable file
    patchShebangs build-aux/postinstall.py
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gettext
    appstream-glib
    libxml2
    desktop-file-utils
    python3
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    glib
    libcanberra-gtk3
    libhandy
    adwaita-icon-theme
    gsettings-desktop-schemas
  ];

  doCheck = true;

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "gnome-screenshot";
    };
  };

  meta = {
    description = "Utility used in the GNOME desktop environment for taking screenshots";
    homepage = "https://gitlab.gnome.org/GNOME/gnome-screenshot";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "gnome-screenshot";
    teams = [ lib.teams.gnome ];
  };
})
