{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  dav1d,
  gdk-pixbuf,
  # for passthru.tests
  gimp,
  imagemagick,
  imlib2Full,
  imv,
  libaom,
  libde265,
  libjpeg,
  libpng,
  pkg-config,
  python3Packages,
  rav1e,
  vips,
  x265,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libheif";
  version = "1.23.1";

  src = fetchFromGitHub {
    owner = "strukturag";
    repo = "libheif";
    rev = "v${finalAttrs.version}";
    hash = "sha256-o+gQCv/lpRx+IaqpjHACh8ysgl/N4Mo/9zbAI/cnWas=";
  };

  outputs = [
    "bin"
    "out"
    "dev"
    "man"
    "lib"
  ];

  nativeBuildInputs = [
    pkg-config
    cmake
  ];

  buildInputs = [
    dav1d
    rav1e
    libde265
    x265
    libpng
    libjpeg
    libaom
    gdk-pixbuf
  ];

  # Fix installation path for gdk-pixbuf module
  env.PKG_CONFIG_GDK_PIXBUF_2_0_GDK_PIXBUF_MODULEDIR = "${placeholder "lib"}/${gdk-pixbuf.moduleDir}";

  postInstall = ''
    substituteInPlace $out/share/thumbnailers/heif.thumbnailer \
      --replace-fail "TryExec=heif-thumbnailer" "TryExec=$bin/bin/heif-thumbnailer" \
      --replace-fail "Exec=heif-thumbnailer" "Exec=$bin/bin/heif-thumbnailer"
  '';

  # Wrong include path in .cmake.  It's a bit difficult to patch because of special characters.
  postFixup = ''
    sed '/^  INTERFACE_INCLUDE_DIRECTORIES/s|"[^"]*/include"|"${placeholder "dev"}/include"|' \
      -i "$dev"/lib/cmake/libheif/libheif-config.cmake
  '';

  passthru.tests = {
    inherit
      gimp
      imagemagick
      imlib2Full
      imv
      vips
      ;

    inherit (python3Packages) pillow-heif;
  };

  meta = {
    description = "ISO/IEC 23008-12:2017 HEIF image file format decoder and encoder";
    homepage = "http://www.libheif.org/";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ kuflierl ];
    platforms = lib.platforms.unix;
  };
})
