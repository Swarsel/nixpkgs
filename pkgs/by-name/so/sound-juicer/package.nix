{
  lib,
  stdenv,
  fetchurl,
  adwaita-icon-theme,
  brasero,
  glib,
  gnome,
  gsettings-desktop-schemas,
  gst_all_1,
  gtk3,
  isocodes,
  itstool,
  libcanberra-gtk3,
  libdiscid,
  libmusicbrainz,
  libxml2,
  meson,
  ninja,
  pkg-config,
  wrapGAppsHook3,
}:

stdenv.mkDerivation rec {
  pname = "sound-juicer";
  version = "3.40.0";

  src = fetchurl {
    url = "mirror://gnome/sources/sound-juicer/${lib.versions.majorMinor version}/sound-juicer-${version}.tar.xz";
    sha256 = "LuiCdEORvrTG1koPaCX7dlUQtwbsK3BL+0LkKvquHeY=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    itstool
    libxml2
    wrapGAppsHook3
  ];

  buildInputs = [
    glib
    gtk3
    brasero
    libcanberra-gtk3
    adwaita-icon-theme
    gsettings-desktop-schemas
    libmusicbrainz
    libdiscid
    isocodes
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-libav
  ];

  passthru = {
    updateScript = gnome.updateScript {
      packageName = pname;
    };
  };

  meta = {
    description = "Gnome CD Ripper";
    homepage = "https://gitlab.gnome.org/GNOME/sound-juicer";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.bdimcheff ];
    platforms = lib.platforms.linux;
    mainProgram = "sound-juicer";
  };
}
