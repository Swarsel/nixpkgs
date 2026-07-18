{
  lib,
  stdenv,
  fetchurl,
  bzip2,
  diffoscopeMinimal,
  enlightenment,
  feh,
  fluxbox,
  freetype,
  giflib,
  gitUpdater,
  icewm,
  # for passthru.tests
  libcaca,
  libheif,
  # imlib2 can load images from ID3 tags.
  libid3tag,
  # Image file formats
  libjpeg,
  libjxl,
  libpng,
  librsvg,
  libspectre,
  libtiff,
  libwebp,
  libxext,
  libxft,
  openbox,
  pkg-config,
  testers,
  heifSupport ? false,
  jxlSupport ? false,
  psSupport ? false,
  svgSupport ? false,
  webpSupport ? true,
  x11Support ? true,
}:

let
  inherit (lib) optional optionals;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "imlib2";
  version = "1.12.6";

  src = fetchurl {
    url = "mirror://sourceforge/enlightenment/imlib2-${finalAttrs.version}.tar.xz";
    hash = "sha256-JQ+XUvadxSLlKagaqpOVcF9/wxL/JFPl3lmsK6HyhY8=";
  };

  outputs = [
    "bin"
    "out"
    "dev"
  ];

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libjpeg
    libtiff
    giflib
    libpng
    bzip2
    freetype
    libid3tag
  ]
  ++ optionals x11Support [
    libxft
    libxext
  ]
  ++ optional heifSupport libheif
  ++ optional svgSupport librsvg
  ++ optional webpSupport libwebp
  ++ optional jxlSupport libjxl
  ++ optional psSupport libspectre;

  # Do not build amd64 assembly code on Darwin, because it fails to compile
  # with unknown directive errors
  configureFlags =
    optional stdenv.hostPlatform.isDarwin "--enable-amd64=no"
    ++ optional (!svgSupport) "--without-svg"
    ++ optional (!heifSupport) "--without-heif"
    ++ optional (!x11Support) "--without-x";

  enableParallelBuilding = true;

  passthru = {
    tests = {
      inherit
        libcaca
        diffoscopeMinimal
        feh
        icewm
        openbox
        fluxbox
        enlightenment
        ;

      pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;
    };

    updateScript = gitUpdater {
      rev-prefix = "v";
      # No nicer place to find latest release.
      url = "https://git.enlightenment.org/old/legacy-imlib2.git";
    };
  };

  meta = {
    description = "Image manipulation library";

    longDescription = ''
      This is the Imlib 2 library - a library that does image file loading and
      saving as well as rendering, manipulation, arbitrary polygon support, etc.
      It does ALL of these operations FAST. Imlib2 also tries to be highly
      intelligent about doing them, so writing naive programs can be done
      easily, without sacrificing speed.
    '';

    homepage = "https://docs.enlightenment.org/api/imlib2/html";
    changelog = "https://git.enlightenment.org/old/legacy-imlib2/raw/tag/v${finalAttrs.version}/ChangeLog";
    license = lib.licenses.imlib2;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    pkgConfigModules = [ "imlib2" ];
  };
})
