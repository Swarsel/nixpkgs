{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pngcheck";
  version = "4.0.1";

  src = fetchFromGitHub {
    owner = "pnggroup";
    repo = "pngcheck";
    rev = "v${finalAttrs.version}";
    hash = "sha256-1cBcSCkiJmHVgYVCY5Em1UtiyAXgd6djEAChrXptTQM=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ zlib ];

  meta = {
    description = "Verifies the integrity of PNG, JNG and MNG files";
    homepage = "https://www.libpng.org/pub/png/apps/pngcheck.html";
    license = lib.licenses.hpnd;
    maintainers = with lib.maintainers; [ starcraft66 ];
    platforms = lib.platforms.unix;
    mainProgram = "pngcheck";
  };
})
