{
  lib,
  stdenv,
  fetchFromGitHub,
  aml,
  ffmpeg,
  gnutls,
  libdrm,
  libgbm,
  libjpeg_turbo,
  meson,
  nettle,
  ninja,
  openssl,
  pixman,
  pkg-config,
  python3,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "neatvnc";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "any1";
    repo = "neatvnc";
    rev = "v${finalAttrs.version}";
    hash = "sha256-ZQdx3NvoFh+lubF1tglYBeEBb4XpD5I1mN3ufibD+uA=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    aml
    ffmpeg
    gnutls
    libdrm
    libjpeg_turbo
    libgbm
    nettle
    pixman
    zlib
  ];

  mesonFlags = [
    (lib.mesonBool "tests" finalAttrs.finalPackage.doCheck)
  ];

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

  nativeCheckInputs = [
    python3
    openssl
  ];

  __structuredAttrs = true;

  meta = {
    description = "VNC server library";

    longDescription = ''
      This is a liberally licensed VNC server library that's intended to be
      fast and neat. Goals:
      - Speed
      - Clean interface
      - Interoperability with the Freedesktop.org ecosystem
    '';

    homepage = "https://github.com/any1/neatvnc";
    changelog = "https://github.com/any1/neatvnc/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ nickcao ];
    platforms = lib.platforms.linux;
  };
})
