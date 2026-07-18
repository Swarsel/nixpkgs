{
  lib,
  stdenv,
  fetchurl,
  fuse,
  glib,
  libgphoto2,
  libtool,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gphoto2fs";
  version = "0.5.0";

  src = fetchurl {
    url = "mirror://sourceforge/gphoto/gphotofs/${finalAttrs.version}/gphotofs-0.5.tar.bz2";
    hash = "sha256-Z27E3mmoHBk//DG9x7WHrCosw3gLFPDnycTApRezQ8w=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libgphoto2
    fuse
    glib
    libtool
  ];

  meta = {
    description = "Fuse FS to mount a digital camera";
    homepage = "http://www.gphoto.org/";

    license = with lib.licenses; [
      lgpl2
      gpl2
    ];

    maintainers = [ lib.maintainers.raskin ];
    platforms = lib.platforms.linux;
    mainProgram = "gphotofs";
  };
})
