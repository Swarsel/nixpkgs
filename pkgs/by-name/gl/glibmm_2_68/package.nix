{
  lib,
  stdenv,
  fetchurl,
  glib,
  gnome,
  gnum4,
  libsigcxx30,
  meson,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "glibmm";
  version = "2.88.0";

  src = fetchurl {
    url = "mirror://gnome/sources/glibmm/${lib.versions.majorMinor finalAttrs.version}/glibmm-${finalAttrs.version}.tar.xz";
    hash = "sha256-plSdo6bEPeg7hxfa5UE8V6YNkvbsxiRhXGEtC7CtD+I=";
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
    libsigcxx30
  ];

  doCheck = false; # fails. one test needs the net, another /etc/fstab

  passthru = {
    updateScript = gnome.updateScript {
      attrPath = "glibmm_2_68";
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
    teams = [ lib.teams.gnome ];
  };
})
