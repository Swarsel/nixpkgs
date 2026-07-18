{
  lib,
  stdenv,
  fetchurl,
  atk,
  glibmm,
  gnome,
  meson,
  ninja,
  pkg-config,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "atkmm";
  version = "2.28.5";

  src = fetchurl {
    url = "mirror://gnome/sources/atkmm/${lib.versions.majorMinor finalAttrs.version}/atkmm-${finalAttrs.version}.tar.xz";
    sha256 = "sha256-rkSRkqWColgqleBgKxXXkrvWOeg2M5uB75FqqHVArFw=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    pkg-config
    meson
    python3
    ninja
  ];

  propagatedBuildInputs = [
    atk
    glibmm
  ];

  doCheck = true;

  passthru = {
    updateScript = gnome.updateScript {
      freeze = true;
      packageName = "atkmm";
      versionPolicy = "odd-unstable";
    };
  };

  meta = {
    description = "C++ wrappers for ATK accessibility toolkit";
    homepage = "https://gtkmm.org";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.unix;
  };
})
