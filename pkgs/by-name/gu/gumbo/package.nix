{
  lib,
  stdenv,
  autoreconfHook,
  fetchFromCodeberg,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gumbo";
  version = "0.13.2";

  src = fetchFromCodeberg {
    owner = "gumbo-parser";
    repo = "gumbo-parser";
    rev = finalAttrs.version;
    hash = "sha256-8mri7mLZkuIZgzE6p0yc41bNNyzGTV9V90OiA/9TkkU=";
  };

  nativeBuildInputs = [ autoreconfHook ];
  enableParallelBuilding = true;

  meta = {
    description = "C99 HTML parsing algorithm";
    homepage = "https://codeberg.org/gumbo-parser/gumbo-parser";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.nico202 ];
    platforms = with lib.platforms; linux ++ darwin;
  };
})
