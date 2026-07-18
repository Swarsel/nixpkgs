{
  lib,
  stdenv,
  fetchurl,
  bzip2,
  callPackage,
  coreutils,
  fixDarwinDylibNames,
  freetype,
  ghostscript,
  graphviz,
  libheif,
  libjpeg,
  libjxl,
  libpng,
  libtiff,
  libtool,
  libwebp,
  libx11,
  libxml2,
  nukeReferences,
  pkg-config,
  runCommand,
  xz,
  zlib,
  quantumdepth ? 8,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "graphicsmagick";
  version = "1.3.47";

  src = fetchurl {
    url = "mirror://sourceforge/graphicsmagick/GraphicsMagick-${finalAttrs.version}.tar.xz";
    hash = "sha256-lftoLasCBqnbFo0GWWP0/99aYLCyo3WsofRJL7GNBic=";
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [
    nukeReferences
    pkg-config
    xz
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ fixDarwinDylibNames ];

  buildInputs = [
    bzip2
    freetype
    ghostscript
    graphviz
    libx11
    libjpeg
    libjxl
    libheif
    libpng
    libtiff
    libtool
    libwebp
    libxml2
    zlib
  ];

  configureFlags = [
    # specify delegates explicitly otherwise `gm` will invoke the build
    # coreutils for filetypes it doesn't natively support.
    "MVDelegate=${lib.getExe' coreutils "mv"}"
    (lib.enableFeature true "shared")
    (lib.withFeature true "frozenpaths")
    (lib.withFeatureAs true "quantum-depth" (toString quantumdepth))
    (lib.withFeatureAs true "gslib" "yes")
  ];

  # Remove CFLAGS from the binaries to avoid closure bloat.
  # In the past we have had -dev packages in the closure of the binaries solely
  # due to the string references.
  postConfigure = ''
    nuke-refs -e $out ./magick/magick_config.h
  '';

  postInstall = ''
    sed -i 's/-ltiff.*'\'/\'/ $out/bin/*
  '';

  passthru = {
    imagemagick-compat = callPackage ./imagemagick-compat.nix {
      graphicsmagick = finalAttrs.finalPackage;
    };

    tests = {
      issue-157920 =
        runCommand "issue-157920-regression-test"
          {
            buildInputs = [ finalAttrs.finalPackage ];
          }
          ''
            gm convert ${graphviz}/share/doc/graphviz/neatoguide.pdf jpg:$out
          '';
    };
  };

  meta = {
    description = "Swiss army knife of image processing";

    longDescription = ''
      GraphicsMagick is the swiss army knife of image processing, providing a
      robust and efficient collection of tools and libraries which support
      reading, writing, and manipulating an image in over 92 major formats
      including important formats like DPX, GIF, JPEG, JPEG-2000, JXL, PNG, PDF,
      PNM, TIFF, and WebP.
    '';

    homepage = "http://www.graphicsmagick.org";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ ambossmann ];
    platforms = lib.platforms.all;
    mainProgram = "gm";
  };
})
