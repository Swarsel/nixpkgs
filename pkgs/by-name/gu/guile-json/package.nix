{
  lib,
  stdenv,
  fetchurl,
  guile,
  pkg-config,
  texinfo,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "guile-json";
  version = "4.7.3";

  src = fetchurl {
    url = "mirror://savannah/guile-json/guile-json-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-OLoEjtKdEvBbMsWy+3pReVxEi0HkA6Kxty/wA1gX84g=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    guile
    pkg-config
    texinfo
  ];

  buildInputs = [
    guile
  ];

  makeFlags = [ "GUILE_AUTO_COMPILE=0" ];
  doCheck = true;

  meta = {
    description = "JSON Bindings for GNU Guile";
    homepage = "https://savannah.nongnu.org/projects/guile-json";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ethancedwards8 ];
    platforms = lib.platforms.all;
  };
})
