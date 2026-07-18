{
  lib,
  fetchzip,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "garamond-libre";
  version = "1.4";

  src = fetchzip {
    url = "https://github.com/dbenjaminmiller/garamond-libre/releases/download/${version}/garamond-libre_${version}.zip";
    hash = "sha256-cD/JMICtb6MPIUcWs2VOTHnb/05ma0/KKtPyR4oJlIc=";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall

    install -Dm644 *.otf -t $out/share/fonts/opentype

    runHook postInstall
  '';

  meta = {
    description = "Garamond Libre font family";
    homepage = "https://github.com/dbenjaminmiller/garamond-libre";
    license = lib.licenses.x11;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
}
