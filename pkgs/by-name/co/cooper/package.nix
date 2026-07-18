{
  lib,
  fetchFromGitHub,
  installFonts,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  pname = "cooper";
  version = "1.01-unstable-2025-05-25";

  src = fetchFromGitHub {
    owner = "indestructible-type";
    repo = "Cooper";
    rev = "062a60572254535634569ab23b993a5745bab4ac";
    hash = "sha256-4WaRFvAn32IfeCCDszOsmDxFuKnnADOXj/vj8SZB2mU=";
  };

  outputs = [
    "out"
    "webfont"
  ];

  nativeBuildInputs = [ installFonts ];

  meta = {
    description = "Cooper* a revival of the Cooper font family by indestructible type*";
    homepage = "https://indestructibletype.com/Cooper/index.html";
    license = lib.licenses.ofl;
    maintainers = with lib.maintainers; [ gavink97 ];
    platforms = lib.platforms.all;
  };
}
