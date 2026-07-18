{
  lib,
  stdenv,
  fetchurl,
  fltk_1_3,
  libjpeg,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fllog";
  version = "1.2.9";

  src = fetchurl {
    url = "mirror://sourceforge/fldigi/fllog-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-3eJvT9PjHTrMn0/pArUDIIE7T7y1YnayG5PuGokwtRk=";
  };

  nativeBuildInputs = [
    fltk_1_3 # fltk-config
    pkg-config
  ];

  buildInputs = [
    fltk_1_3
    libjpeg
  ];

  meta = {
    description = "Digital modem log program";
    homepage = "https://sourceforge.net/projects/fldigi/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ dysinger ];
    platforms = lib.platforms.linux;
    mainProgram = "fllog";
  };
})
