{
  lib,
  stdenv,
  fetchurl,
  libx11,
  libxcb,
  libxcb-util,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libstartup-notification";
  version = "0.12";

  src = fetchurl {
    url = "https://www.freedesktop.org/software/startup-notification/releases/startup-notification-${finalAttrs.version}.tar.gz";
    sha256 = "3c391f7e930c583095045cd2d10eb73a64f085c7fde9d260f2652c7cb3cfbe4a";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libx11
    libxcb
    libxcb-util
  ];

  configureFlags = lib.optionals (stdenv.buildPlatform != stdenv.hostPlatform) [
    "lf_cv_sane_realloc=yes"
  ];

  meta = {
    description = "Application startup notification and feedback library";
    homepage = "https://www.freedesktop.org/software/startup-notification";
    license = lib.licenses.lgpl2;
  };
})
