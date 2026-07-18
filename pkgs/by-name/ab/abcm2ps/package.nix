{
  lib,
  stdenv,
  docutils,
  fetchfossil,
  freetype,
  pango,
  pkg-config,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "abcm2ps";
  version = "8.14.18";

  src = fetchfossil {
    url = "https://chiselapp.com/user/moinejf/repository/abcm2ps";
    rev = "v${finalAttrs.version}";
    hash = "sha256-2nmKjLEZ9dTk+oE16gBm9iheVlLvQFvcdc5FPcxaq6M=";
  };

  nativeBuildInputs = [
    docutils
    pkg-config
  ];

  buildInputs = [
    freetype
    pango
  ];

  configureFlags = [
    "--INSTALL=install"
  ];

  passthru.tests = {
    version = testers.testVersion {
      command = "abcm2ps -V";
      package = finalAttrs.finalPackage;
    };
  };

  meta = {
    description = "Command line program which converts ABC to music sheet in PostScript or SVG format";
    homepage = "http://moinejf.free.fr/";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ dotlambda ];
    platforms = lib.platforms.unix;
    mainProgram = "abcm2ps";
  };
})
