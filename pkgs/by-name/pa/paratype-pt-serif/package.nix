{
  lib,
  fetchFromGitHub,
  installFonts,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "paratype-pt-serif";
  version = "1.000";

  src = fetchFromGitHub {
    owner = "google";
    repo = "fonts";
    rev = "a4f3deeca2d7547351ff746f7bf3b51f5528dbcf";
    hash = "sha256-HpA4r5VqAVtPFY9ltRUeZERNfyFRkAvwununoDF+5mk=";
    rootDir = "ofl/ptserif";
  };

  nativeBuildInputs = [ installFonts ];

  meta = {
    description = "Open Paratype font";
    homepage = "https://www.paratype.ru/catalog/font/pt/pt-serif";
    license = lib.licenses.ofl;

    maintainers = with lib.maintainers; [
      raskin
      pancaek
    ];

    platforms = lib.platforms.all;
  };
}
