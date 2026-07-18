{
  lib,
  stdenv,
  fetchFromGitHub,
  libGL,
  libdisplay-info,
  libdrm,
  libgbm,
  libinput,
  meson,
  ninja,
  pkg-config,
  seatd,
  udev,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "srm-cuarzo";
  version = "0.13.0-1";

  src = fetchFromGitHub {
    inherit (finalAttrs) rev hash;
    owner = "CuarzoSoftware";
    repo = "SRM";
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
    libdisplay-info
    libdrm
    libGL
    libinput
    libgbm
    seatd
    udev
  ];

  preConfigure = ''
    # The root meson.build file is in src/
    cd src
  '';

  hash = "sha256-5BwLqAZdfO5vyEMPZImaxymvLoNuu6bOiOkvR8JERxg=";
  rev = "v${finalAttrs.version}";

  meta = {
    description = "Simple Rendering Manager";
    homepage = "https://github.com/CuarzoSoftware/SRM";
    license = lib.licenses.lgpl21Only;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
