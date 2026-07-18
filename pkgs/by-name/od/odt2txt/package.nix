{
  lib,
  stdenv,
  fetchurl,
  libiconv,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "odt2txt";
  version = "0.5";

  src = fetchurl {
    url = "${finalAttrs.meta.homepage}/archive/v${finalAttrs.version}.tar.gz";
    sha256 = "23a889109ca9087a719c638758f14cc3b867a5dcf30a6c90bf6a0985073556dd";
  };

  buildInputs = [
    zlib
    libiconv
  ];

  configurePhase = "export makeFlags=\"DESTDIR=$out\"";

  meta = {
    description = "Simple .odt to .txt converter";
    homepage = "https://github.com/dstosberg/odt2txt";
    license = lib.licenses.gpl2Only;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "odt2txt";
  };
})
