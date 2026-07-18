{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  fetchpatch,
  libusb1,
  meson,
  microsoft-gsl,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ite-backlight";
  version = "1.1";

  src = fetchFromGitHub {
    owner = "hexagonal-sun";
    repo = "ite-backlight";
    rev = "v${finalAttrs.version}";
    sha256 = "1hany4bn93mac9qyz97r1l858d48zdvvmn3mabzr3441ivqr9j0a";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-iTRTVy7qB2z1ip135b8k3RufTBzeJaP1wdrRWN9tPsU=";
      name = "fix-gcc13-build-failure.patch";
      url = "https://github.com/hexagonal-sun/ite-backlight/commit/dc8c19d4785d80cbe7a82869daee1f723d3f3fb2.patch";
    })
  ];

  nativeBuildInputs = [
    ninja
    pkg-config
    meson
    microsoft-gsl
  ];

  buildInputs = [
    boost
    libusb1
  ];

  meta = {
    description = "Commands to control ite-backlight devices";

    longDescription = ''
      This project aims to provide a set of simple utilities for controlling ITE 8291
      keyboard backlight controllers.
    '';

    homepage = "https://github.com/hexagonal-sun/ite-backlight";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ hexagonal-sun ];
    platforms = lib.platforms.linux;
  };
})
