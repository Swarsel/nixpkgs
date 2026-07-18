{
  lib,
  fetchurl,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "fixedsys-excelsior";
  version = "3.00";

  src = fetchurl {
    url = "https://raw.githubusercontent.com/chrissimpkins/codeface/master/fonts/fixed-sys-excelsior/FSEX300.ttf";
    hash = "sha256-buDzVzvF4z6TthbvYoL0m8DiJ6Map1Osdu0uPz0CBW0=";
  };

  installPhase = ''
    runHook preInstall

    install -m444 -D $src $out/share/fonts/truetype/${pname}-${version}.ttf

    runHook postInstall
  '';

  dontUnpack = true;

  meta = {
    description = "Pan-unicode version of Fixedsys, a classic DOS font";
    homepage = "http://www.fixedsysexcelsior.com/";
    license = lib.licenses.publicDomain;
    maintainers = [ lib.maintainers.picnoir ];
    platforms = lib.platforms.all;
  };
}
