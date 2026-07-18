{
  lib,
  fetchurl,
  at-spi2-core,
  buildPythonPackage,
  gnome,
  isPy3k,
  meson,
  ninja,
  pkg-config,
  pygobject3,
}:

buildPythonPackage rec {
  pname = "pyatspi";
  version = "2.58.1";

  src = fetchurl {
    url = "mirror://gnome/sources/pyatspi/${lib.versions.majorMinor version}/pyatspi-${version}.tar.xz";
    sha256 = "Px8HmTX5JlhDMQJcdTGFjetCJFyZO2USH09LAeawRTY=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    at-spi2-core
    pygobject3
  ];

  disabled = !isPy3k;
  pyproject = false;

  passthru = {
    updateScript = gnome.updateScript {
      attrPath = "python3.pkgs.pyatspi";
      packageName = "pyatspi";
      versionPolicy = "odd-unstable";
    };
  };

  meta = {
    description = "Python client bindings for D-Bus AT-SPI";
    homepage = "https://gitlab.gnome.org/GNOME/pyatspi2";
    license = lib.licenses.lgpl2Only;
    maintainers = with lib.maintainers; [ jtojnar ];
    platforms = with lib.platforms; unix;
  };
}
