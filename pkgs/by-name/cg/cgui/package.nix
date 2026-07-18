{
  lib,
  stdenv,
  fetchurl,
  allegro,
  libx11,
  perl,
  texinfo,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cgui";
  version = "2.1.0";

  src = fetchurl {
    url = "mirror://sourceforge/project/cgui/${finalAttrs.version}/cgui-${finalAttrs.version}.tar.gz";
    sha256 = "1pp1hvidpilq37skkmbgba4lvzi01rasy04y0cnas9ck0canv00s";
  };

  patches = [
    ./fix-gcc15.patch
  ];

  buildInputs = [
    texinfo
    allegro
    perl
    libx11
  ];

  makeFlags = [ "SYSTEM_DIR=$(out)" ];

  configurePhase = ''
    runHook preConfigure

    sh fix.sh unix

    runHook postConfigure
  '';

  hardeningDisable = [ "format" ];

  meta = {
    description = "Multiplatform basic GUI library";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.raskin ];
    platforms = lib.platforms.linux;
  };
})
