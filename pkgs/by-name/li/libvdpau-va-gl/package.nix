{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  glib,
  libGLU,
  libpthread-stubs,
  libva,
  libvdpau,
  libx11,
  libxau,
  libxdmcp,
  libxext,
  pkg-config,
}:

stdenv.mkDerivation {
  pname = "libvdpau-va-gl";
  version = "0.4.2-unstable-2025-05-18";

  src = fetchFromGitHub {
    owner = "i-rinat";
    repo = "libvdpau-va-gl";
    rev = "a845e8720d900e4bcc89e7ee16106ce63b44af0d";
    hash = "sha256-CtpyWod+blqC3u12MaQyqFOXurCP5Rb2PYq7PoaoASA=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    libx11
    libpthread-stubs
    libxau
    libxdmcp
    libxext
    libvdpau
    glib
    libva
    libGLU
  ];

  doCheck = false; # fails. needs DRI access

  meta = {
    description = "VDPAU driver with OpenGL/VAAPI backend";
    homepage = "https://github.com/i-rinat/libvdpau-va-gl";
    license = lib.licenses.lgpl3;
    maintainers = [ lib.maintainers.johnrtitor ];
    platforms = lib.platforms.linux;
  };
}
