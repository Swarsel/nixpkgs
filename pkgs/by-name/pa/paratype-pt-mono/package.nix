{
  lib,
  fetchFromGitHub,
  installFonts,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "paratype-pt-mono";
  version = "1.001";

  src = fetchFromGitHub {
    owner = "google";
    repo = "fonts";
    rev = "a4f3deeca2d7547351ff746f7bf3b51f5528dbcf";
    hash = "sha256-wzm6KzO/arar7VMvm0l0L6gi3CnglmZKSGe7c0i530Q=";
    rootDir = "ofl/ptmono";
  };

  nativeBuildInputs = [ installFonts ];

  meta = {
    description = "Open Paratype font";
    homepage = "https://www.paratype.ru/catalog/font/pt/pt-mono";
    license = lib.licenses.ofl;

    maintainers = with lib.maintainers; [
      raskin
      pancaek
    ];

    platforms = lib.platforms.all;
  };
}
