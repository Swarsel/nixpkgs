{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gpx";
  version = "2.6.8";

  src = fetchFromGitHub {
    owner = "markwal";
    repo = "GPX";
    rev = finalAttrs.version;
    sha256 = "1izs8s5npkbfrsyk17429hyl1vyrbj9dp6vmdlbb2vh6mfgl54h8";
  };

  nativeBuildInputs = [ autoreconfHook ];

  meta = {
    description = "Gcode to x3g conversion postprocessor";
    homepage = "https://github.com/markwal/GPX/";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.leo60228 ];
    platforms = lib.platforms.unix;
  };
})
