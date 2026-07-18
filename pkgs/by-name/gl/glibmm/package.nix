{
  lib,
  stdenv,
  fetchurl,
  glib,
  gnome,
  gnum4,
  libsigcxx,
  meson,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "glibmm";
  version = "2.66.8";

  src = fetchurl {
    url = "mirror://gnome/sources/glibmm/${lib.versions.majorMinor finalAttrs.version}/glibmm-${finalAttrs.version}.tar.xz";
    hash = "sha256-ZPEdO5WiTiqNQWbs/1GHMPeezCciLvQfr3x+A0D8kyk=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    meson
    pkg-config
    ninja
    gnum4
    glib # for glib-compile-schemas
  ];

  propagatedBuildInputs = [
    glib
    libsigcxx
  ];

  doCheck = false; # fails. one test needs the net, another /etc/fstab

  passthru = {
    updateScript = gnome.updateScript {
      freeze = true;
      packageName = "glibmm";
      versionPolicy = "odd-unstable";
    };
  };

  meta = {
    description = "C++ interface to the GLib library";
    homepage = "https://gtkmm.org/";
    license = lib.licenses.lgpl2Plus;
    maintainers = with lib.maintainers; [ raskin ];
    platforms = lib.platforms.unix;
  };
})
