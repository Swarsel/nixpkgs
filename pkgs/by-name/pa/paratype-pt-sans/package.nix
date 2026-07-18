{
  lib,
  fetchFromGitHub,
  installFonts,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "paratype-pt-sans";
  version = "2.003";

  src = fetchFromGitHub {
    owner = "google";
    repo = "fonts";
    rev = "a4f3deeca2d7547351ff746f7bf3b51f5528dbcf";
    hash = "sha256-44G9Pdi4GxeC9hzvCKuE7AmHyjVrjzalr3XZOgl3l6o=";
    rootDir = "ofl/ptsans";
  };

  nativeBuildInputs = [ installFonts ];

  meta = {
    description = "Open Paratype font";
    homepage = "https://www.paratype.ru/catalog/font/pt/pt-sans";
    license = lib.licenses.ofl;

    maintainers = with lib.maintainers; [
      raskin
      pancaek
    ];

    platforms = lib.platforms.all;
  };
}
