{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  SDL2_image,
  SDL2_mixer,
  SDL2_ttf,
  cmake,
  fmt,
  gettext,
  include-what-you-use,
  libtiff,
  libwebp,
  libx11,
  libxml2,
  libxmlxx5,
  libxslt,
  pkg-config,
  xorgproto,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lincity-ng";
  version = "2.14.2";

  src = fetchFromGitHub {
    owner = "lincity-ng";
    repo = "lincity-ng";
    tag = "lincity-ng-${finalAttrs.version}";
    hash = "sha256-HW+bB9xnrok8tWKIJJUt3Qgo5e9HmI6NZORG4PazmEM=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
    gettext
    include-what-you-use
    libxml2
    libxslt
  ];

  buildInputs = [
    fmt
    SDL2
    SDL2_image
    SDL2_mixer
    SDL2_ttf
    libx11
    libwebp
    libtiff
    libxmlxx5
    libxml2
    libxslt
    xorgproto
    zlib
  ];

  cmakeFlags = [
    "-DLIBXML2_LIBRARY=${lib.getLib libxml2}/lib/libxml2${stdenv.hostPlatform.extensions.sharedLibrary}"
    "-DLIBXML2_XMLCATALOG_EXECUTABLE=${lib.getBin libxml2}/bin/xmlcatalog"
    "-DLIBXML2_XMLLINT_EXECUTABLE=${lib.getBin libxml2}/bin/xmllint"
  ];

  env.NIX_CFLAGS_COMPILE = "
    -I${lib.getDev SDL2_image}/include/SDL2
    -I${lib.getDev SDL2_mixer}/include/SDL2
  ";

  hardeningDisable = [ "format" ];

  meta = {
    description = "City building game";
    homepage = "https://github.com/lincity-ng/lincity-ng";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      raskin
      iedame
    ];

    platforms = lib.platforms.linux;
    mainProgram = "lincity-ng";
  };
})
