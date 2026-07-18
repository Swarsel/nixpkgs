{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  buildPackages,
  bzip2,
  glib,
  imagemagick,
  libgsf,
  libpng,
  libxml2,
  pkg-config,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wv";
  version = "1.2.9";

  src = fetchFromGitHub {
    owner = "AbiWord";
    repo = "wv";
    rev = "wv-${builtins.replaceStrings [ "." ] [ "-" ] finalAttrs.version}";
    hash = "sha256-xcC+/M1EzFqQFeF5Dw9qd8VIy7r8JdKMp2X/GHkFiPA=";
  };

  # autoreconfHook fails hard if these two files do not exist.
  # The extra move is to work around case-insensitive filesystems.
  postPatch = ''
    touch AUTHORS
    mv CHANGELOG ChangeLog~ && mv ChangeLog~ ChangeLog
  '';

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
  ];

  buildInputs = [
    zlib
    imagemagick
    libpng
    glib
    libgsf
    libxml2
    bzip2
  ];

  configureFlags = [
    "PKG_CONFIG=${buildPackages.pkg-config}/bin/${buildPackages.pkg-config.targetPrefix}pkg-config"
  ];

  env.NIX_CFLAGS_COMPILE =
    # Suppress incompatible function pointer and int conversion errors when building with newer versions of clang 16.
    lib.optionalString stdenv.cc.isClang
      "-Wno-error=incompatible-function-pointer-types -Wno-error=int-conversion";

  enableParallelBuilding = true;
  hardeningDisable = [ "format" ];

  meta = {
    description = "Converter from Microsoft Word formats to human-editable ones";
    homepage = "https://github.com/AbiWord/wv";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
  };
})
