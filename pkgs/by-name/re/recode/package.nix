{
  lib,
  stdenv,
  fetchurl,
  flex,
  libiconv,
  libintl,
  perl,
  python3Packages,
  texinfo,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "recode";
  version = "3.7.15";

  # Use official tarball, avoid need to bootstrap/generate build system
  src = fetchurl {
    url = "https://github.com/rrthomas/recode/releases/download/v${finalAttrs.version}/recode-${finalAttrs.version}.tar.gz";
    hash = "sha256-9ZBAf8UbrbNRlz/BMz7jMRHwXsg6j5VP2M8MXjBDmAY=";
  };

  nativeBuildInputs = [
    python3Packages.python
    perl
    flex
    texinfo
    libiconv
  ];

  buildInputs = [ libintl ];
  doCheck = true;

  nativeCheckInputs = with python3Packages; [
    cython
    setuptools
  ];

  enableParallelBuilding = true;

  meta = {
    description = "Converts files between various character sets and usages";
    homepage = "https://github.com/rrthomas/recode";
    changelog = "https://github.com/rrthomas/recode/raw/v${finalAttrs.version}/NEWS";

    license = with lib.licenses; [
      lgpl3Plus
      gpl3Plus
    ];

    maintainers = with lib.maintainers; [ jcumming ];
    platforms = lib.platforms.unix;
    mainProgram = "recode";
  };
})
