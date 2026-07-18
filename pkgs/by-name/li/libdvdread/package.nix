{
  lib,
  stdenv,
  fetchurl,
  libdvdcss,
  meson,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libdvdread";
  version = "7.0.1";

  src = fetchurl {
    url = "https://get.videolan.org/libdvdread/${finalAttrs.version}/libdvdread-${finalAttrs.version}.tar.xz";
    hash = "sha256-Lj4EowXBXDljqgOuG5qDwdI5iAAD/PPd6YbTlDNV1Ac=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [ libdvdcss ];

  mesonFlags = [
    (lib.mesonEnable "libdvdcss" true)
  ];

  postInstall = ''
    ln -s dvdread $out/include/libdvdread
  '';

  meta = {
    description = "Library for reading DVDs";
    homepage = "http://dvdnav.mplayerhq.hu/";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.wmertens ];
    platforms = lib.platforms.unix;
  };
})
