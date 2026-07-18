{
  lib,
  fetchFromGitHub,
  buildNimPackage,
  pcre,
  termbox,
}:

buildNimPackage (finalAttrs: {
  pname = "nimmm";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "joachimschmidt557";
    repo = "nimmm";
    rev = "v${finalAttrs.version}";
    hash = "sha256-NK2OH5eAlcityUdz9p95Y7iNOX39ed0Krdns1+2NKLU=";
  };

  buildInputs = [
    termbox
  ];

  lockFile = ./lock.json;

  meta = {
    description = "Terminal file manager for Linux";
    homepage = "https://github.com/joachimschmidt557/nimmm";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.joachimschmidt557 ];
    platforms = lib.platforms.linux;
    mainProgram = "nimmm";
  };
})
