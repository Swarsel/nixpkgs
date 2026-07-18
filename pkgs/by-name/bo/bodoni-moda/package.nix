{
  lib,
  fetchFromGitHub,
  installFonts,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  pname = "bodoni-moda";
  version = "2.4-unstable-2024-02-18";

  src = fetchFromGitHub {
    owner = "indestructible-type";
    repo = "Bodoni";
    rev = "30ce6cdc354ef179a3b72ba0f0e71826e599348c";
    hash = "sha256-OQi+KKBM+BrmA2pDit6dib5krrQBba5dVCBd2/G5sIM=";
  };

  outputs = [
    "out"
    "webfont"
  ];

  nativeBuildInputs = [ installFonts ];

  meta = {
    description = "Bodoni Moda a modern no-compromises Bodoni family by indestructible type*";
    homepage = "https://indestructibletype.com/Bodoni.html";
    license = lib.licenses.ofl;
    maintainers = with lib.maintainers; [ gavink97 ];
    platforms = lib.platforms.all;
  };
}
