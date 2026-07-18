{
  lib,
  stdenv,
  fetchurl,
  gd,
  ghostscript,
  imagemagick,
  libiconv,
  libjpeg,
  libwebp,
  makeWrapper,
  pkg-config,
  plotutils,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pstoedit";
  version = "4.02";

  src = fetchurl {
    url = "mirror://sourceforge/pstoedit/pstoedit-${finalAttrs.version}.tar.gz";
    hash = "sha256-VYi0MtLGsq2YKLRJFepYE/+aOjMSpB+g3kw43ayd9y8=";
  };

  outputs = [
    "out"
    "dev"
  ];

  postPatch = ''
    # don't use gnu-isms like link.h on macos
    substituteInPlace src/pstoedit.cpp --replace-fail '#ifndef _MSC_VER' '#if !defined(_MSC_VER) && !defined(__APPLE__)'
  '';

  nativeBuildInputs = [
    makeWrapper
    pkg-config
  ];

  buildInputs = [
    zlib
    ghostscript
    imagemagick
    plotutils
    gd
    libjpeg
    libwebp
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    libiconv
  ];

  postInstall = ''
    wrapProgram $out/bin/pstoedit \
      --prefix PATH : ${lib.makeBinPath [ ghostscript ]}
  '';

  meta = {
    description = "Translates PostScript and PDF graphics into other vector formats";
    homepage = "https://sourceforge.net/projects/pstoedit/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "pstoedit";
  };
})
