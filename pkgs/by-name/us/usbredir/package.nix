{
  lib,
  stdenv,
  fetchFromGitLab,
  glib,
  libusb1,
  meson,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "usbredir";
  version = "0.15.0";

  src = fetchFromGitLab {
    owner = "spice";
    repo = "usbredir";
    rev = "${pname}-${version}";
    sha256 = "sha256-a+RaJO70jxsrVwSG+PzDg2luvBHqBdNdRdLOGhdhjzY=";
    domain = "gitlab.freedesktop.org";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    glib
  ];

  propagatedBuildInputs = [
    libusb1
  ];

  mesonFlags = [
    "-Dgit_werror=disabled"
    "-Dtools=enabled"
    "-Dfuzzing=disabled"
  ];

  meta = {
    description = "USB traffic redirection protocol";
    homepage = "https://www.spice-space.org/usbredir.html";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "usbredirect";
  };
}
