{
  lib,
  stdenv,
  fetchurl,
  atk,
  glibmm_2_68,
  gnome,
  meson,
  ninja,
  pkg-config,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "atkmm";
  version = "2.36.3";

  src = fetchurl {
    url = "mirror://gnome/sources/atkmm/${lib.versions.majorMinor finalAttrs.version}/atkmm-${finalAttrs.version}.tar.xz";
    sha256 = "sha256-bsJk6qDE3grbcgLGABcL3pp/vk1Ga/vpQOr3+qpsWXQ=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    python3
  ];

  propagatedBuildInputs = [
    atk
    glibmm_2_68
  ];

  doCheck = true;

  passthru = {
    updateScript = gnome.updateScript {
      attrPath = "atkmm_2_36";
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
