{
  lib,
  fetchurl,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "curie";
  version = "1.0";

  src = fetchurl {
    url = "https://github.com/oppiliappan/curie/releases/download/v${version}/curie-v${version}.tar.gz";
    hash = "sha256-B89GNbOmm3lY/cRWQJEFu/5morCM/WrRQb/m6covbt8=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fonts/misc
    install *.otb $out/share/fonts/misc

    runHook postInstall
  '';

  sourceRoot = ".";

  meta = {
    description = "Upscaled version of scientifica";
    homepage = "https://github.com/oppiliappan/curie";
    license = lib.licenses.ofl;
    maintainers = with lib.maintainers; [ moni ];
    platforms = lib.platforms.all;
  };
}
