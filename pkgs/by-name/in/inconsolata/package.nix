{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "inconsolata";
  version = "3.001";

  src = fetchFromGitHub {
    owner = "google";
    repo = "fonts";
    rev = "0f203e3740b5eb77e0b179dff1e5869482676782";
    hash = "sha256-4+aIjVO9/L4mCWGYqL1drFehHZTjRL25vTwh3c7GoFk=";
    rootDir = "ofl/inconsolata";
  };

  installPhase = ''
    runHook preInstall
    install -m644 --target $out/share/fonts/truetype/inconsolata -D static/*.ttf *.ttf
    runHook postInstall
  '';

  meta = {
    description = "Monospace font for both screen and print";
    homepage = "https://www.levien.com/type/myfonts/inconsolata.html";
    license = lib.licenses.ofl;

    maintainers = with lib.maintainers; [
      appsforartists
      mikoim
      raskin
    ];

    platforms = lib.platforms.all;
  };
}
