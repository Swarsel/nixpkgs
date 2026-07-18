{
  lib,
  stdenv,
  fetchurl,
  audiofile,
  bzip2,
  glib,
  libgcrypt,
  perl,
  pkg-config,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libspectrum";
  version = "1.6.0";

  src = fetchurl {
    url = "mirror://sourceforge/fuse-emulator/libspectrum-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-rH7jqYEQjk85hikTe4Cd6L4w5qbglFNryNLhQxPMwKo=";
  };

  nativeBuildInputs = [
    perl
    pkg-config
  ];

  buildInputs = [
    audiofile
    bzip2
    glib
    libgcrypt
    zlib
  ];

  doCheck = true;
  enableParallelBuilding = true;

  meta = {
    description = "ZX Spectrum input and output support library";
    homepage = "https://fuse-emulator.sourceforge.net/libspectrum.php";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
