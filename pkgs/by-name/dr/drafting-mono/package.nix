{
  lib,
  fetchFromGitHub,
  installFonts,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "drafting-mono";
  version = "1.1-unstable-2024-06-04";

  src = fetchFromGitHub {
    owner = "indestructible-type";
    repo = "Drafting";
    rev = "c387df13576c3b541352725b021f9f99302e52d6";
    hash = "sha256-J64mmDOzTV4MRuZO3MB2SSX5agCRjLDjXAPXuDfdlOM=";
  };

  outputs = [
    "out"
    "webfont"
  ];

  nativeBuildInputs = [ installFonts ];

  meta = {
    description = "Drafting* Mono a mixed serif typewriter inspired font by indestructible type*";
    homepage = "https://indestructibletype.com/Drafting/";
    license = lib.licenses.ofl;
    maintainers = with lib.maintainers; [ gavink97 ];
    platforms = lib.platforms.all;
  };
}
