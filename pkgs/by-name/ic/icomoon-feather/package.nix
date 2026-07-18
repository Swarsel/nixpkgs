{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  pname = "icomoon-feather";
  version = "0-unstable-2024-05-11";

  src = fetchFromGitHub {
    owner = "adi1090x";
    repo = "polybar-themes";
    rev = "adb6a4546a8351a469fa779df173e46b69aa1ac3";
    hash = "sha256-QL7/pfIqOd2JOm6rkH+P4rMg0AhGllfkReQ03YeGW+8=";
    sparseCheckout = [ "fonts/panels/icomoon_feather.ttf" ];
  };

  installPhase = ''
    runHook preInstall

    install -Dm644 fonts/panels/icomoon_feather.ttf -t $out/share/fonts/truetype/

    runHook postInstall
  '';

  meta = {
    description = "Icomoon feather font";
    homepage = "https://github.com/adi1090x/polybar-themes/tree/master/fonts/panels";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ luftmensch-luftmensch ];
    platforms = lib.platforms.all;
  };
}
