{
  lib,
  stdenv,
  fetchFromGitHub,
  avahi,
  gnutls,
  libjpeg,
  libpng,
  libtiff,
  libxml2,
  meson,
  ninja,
  pkg-config,
  sane-backends,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "sane-airscan";
  version = "0.99.37";

  src = fetchFromGitHub {
    owner = "alexpevzner";
    repo = "sane-airscan";
    rev = finalAttrs.version;
    sha256 = "sha256-Vm6t4i2UDAzMULM8d0m1W8vNtOh+i4X8oXOEdguudfw=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    avahi
    gnutls
    libjpeg
    libpng
    libxml2
    libtiff
    sane-backends
  ];

  meta = {
    description = "Scanner Access Now Easy - Apple AirScan (eSCL) driver";

    longDescription = ''
      sane-airscan: Linux support of Apple AirScan (eSCL) compatible document scanners.
    '';

    homepage = "https://github.com/alexpevzner/sane-airscan";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ zaninime ];
    platforms = lib.platforms.linux;
    mainProgram = "airscan-discover";
  };
})
