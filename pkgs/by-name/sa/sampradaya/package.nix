{
  lib,
  fetchurl,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "sampradaya";
  version = "0.5.0";

  src = fetchurl {
    url = "https://github.com/deepestblue/sampradaya/releases/download/v${version}/Sampradaya.ttf";
    hash = "sha256-ygKMNzHvbLR2A5HHrfY2C9ZUg0yng+JL3cyg6sBKqeQ=";
  };

  installPhase = ''
    runHook preInstall

    install -Dm644 $src $out/share/fonts/truetype/Sampradaya.ttf

    runHook postInstall
  '';

  dontUnpack = true;

  meta = {
    description = "Unicode-compliant Grantha font";
    homepage = "https://github.com/deepestblue/sampradaya";
    license = lib.licenses.ofl; # See font metadata
    maintainers = with lib.maintainers; [ mathnerd314 ];
    platforms = lib.platforms.all;
  };
}
