{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "nightdiamond-cursors";
  version = "0-unstable-2026-05-11";

  src = fetchFromGitHub {
    owner = "vimlinuz";
    repo = "NightDiamond-cursors";
    rev = "49650765c3396ccee9ffb796608845d4660d5692";
    hash = "sha256-Ue6dDvNMq1pGfzudt1O8h0pawfKj4FskTGLnpyEp0CM=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/icons
    cp -r NightDiamond-* $out/share/icons/
    runHook postInstall
  '';

  meta = {
    description = "NightDiamond cursor themes";
    homepage = "https://github.com/vimlinuz/NightDiamond-cursors";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ vimlinuz ];
    platforms = lib.platforms.linux;
  };
}
