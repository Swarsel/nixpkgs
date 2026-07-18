{
  lib,
  stdenv,
  fetchurl,
  boost,
  cargo,
  gdk-pixbuf,
  glib,
  libjpeg,
  libxml2,
  pkg-config,
  rustc,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libopenraw";
  version = "0.3.7";

  src = fetchurl {
    url = "https://libopenraw.freedesktop.org/download/libopenraw-${finalAttrs.version}.tar.bz2";
    hash = "sha256-VRWyYQNh7zRYC2uXZjURn23ttPCnnVRmL6X+YYakXtU=";
  };

  postPatch = ''
    sed -i configure{,.ac} \
      -e "s,GDK_PIXBUF_DIR=.*,GDK_PIXBUF_DIR=$out/lib/gdk-pixbuf-2.0/2.10.0/loaders,"
  '';

  nativeBuildInputs = [
    pkg-config
    cargo
    rustc
  ];

  buildInputs = [
    boost
    gdk-pixbuf
    glib
    libjpeg
    libxml2
  ];

  configureFlags = [
    "--with-boost=${lib.getDev boost}"
  ];

  meta = {
    description = "RAW camerafile decoding library";
    homepage = "https://libopenraw.freedesktop.org";
    license = lib.licenses.lgpl3Plus;
    maintainers = [ lib.maintainers.struan ];
    platforms = lib.platforms.linux;
  };
})
