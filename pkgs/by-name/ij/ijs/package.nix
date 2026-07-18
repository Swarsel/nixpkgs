{
  lib,
  stdenv,
  autoreconfHook,
  ghostscript,
}:

stdenv.mkDerivation {
  inherit (ghostscript) version src;
  pname = "ijs";
  postPatch = "cd ijs";
  nativeBuildInputs = [ autoreconfHook ];
  configureFlags = [ "--enable-shared" ];
  enableParallelBuilding = true;

  meta = {
    description = "Raster printer driver architecture";
    homepage = "https://www.openprinting.org/download/ijs/";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
}
