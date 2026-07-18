{
  lib,
  stdenv,
  fetchurl,
  gettext,
  gnome,
  meson,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "gnome-video-effects";
  version = "0.6.0";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-video-effects/${lib.versions.majorMinor version}/gnome-video-effects-${version}.tar.xz";
    sha256 = "166utGs/WoMvsuDZC0K/jGFgICylKsmt0Xr84ZLjyKg=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gettext
  ];

  passthru = {
    updateScript = gnome.updateScript {
      packageName = pname;
      versionPolicy = "none";
    };
  };

  meta = {
    description = "Collection of GStreamer effects to be used in different GNOME Modules";
    homepage = "https://gitlab.gnome.org/GNOME/gnome-video-effects";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.unix;
    teams = [ lib.teams.gnome ];
  };
}
