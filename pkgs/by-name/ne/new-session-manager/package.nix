{
  lib,
  stdenv,
  fetchFromGitHub,
  fltk,
  libjack2,
  liblo,
  meson,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "new-session-manager";
  version = "1.6.1";

  src = fetchFromGitHub {
    owner = "jackaudio";
    repo = "new-session-manager";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-5G2GlBuKjC/r1SMm78JKia7bMA97YcvUR5l6zBucemw=";
  };

  nativeBuildInputs = [
    meson
    pkg-config
    ninja
  ];

  buildInputs = [
    liblo
    libjack2
    fltk
  ];

  hardeningDisable = [ "format" ];

  meta = {
    description = "Session manager designed for audio applications";
    homepage = "https://new-session-manager.jackaudio.org/";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers._6AA4FD ];
    platforms = [ "x86_64-linux" ];
  };
})
