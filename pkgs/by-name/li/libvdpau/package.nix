{
  lib,
  stdenv,
  fetchurl,
  libx11,
  libxext,
  mesa,
  meson,
  ninja,
  pkg-config,
  xorgproto,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libvdpau";
  version = "1.5";

  src = fetchurl {
    url = "https://gitlab.freedesktop.org/vdpau/libvdpau/-/archive/${finalAttrs.version}/libvdpau-${finalAttrs.version}.tar.bz2";
    sha256 = "sha256-pdUKQrjCiP68BxUatkOsjeBqGERpZcckH4m06BCCGRM=";
  };

  outputs = [
    "out"
    "dev"
  ];

  patches = [ ./tracing.patch ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    xorgproto
    libxext
  ];

  propagatedBuildInputs = [ libx11 ];

  mesonFlags = lib.optionals stdenv.hostPlatform.isLinux [
    "-Dmoduledir=${mesa.driverLink}/lib/vdpau"
  ];

  env = lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    NIX_LDFLAGS = "-lX11";
  };

  # The tracing library in this package must be conditionally loaded with dlopen().
  # Therefore, we must restore the RPATH entry for the library itself that was removed by the patchelf hook.
  postFixup = lib.optionalString stdenv.hostPlatform.isElf ''
    patchelf $out/lib/libvdpau.so --add-rpath $out/lib
  '';

  meta = {
    description = "Library to use the Video Decode and Presentation API for Unix (VDPAU)";
    homepage = "https://www.freedesktop.org/wiki/Software/VDPAU/";
    license = lib.licenses.mit; # expat version
    maintainers = [ lib.maintainers.vcunat ];
    platforms = lib.platforms.unix;
  };
})
