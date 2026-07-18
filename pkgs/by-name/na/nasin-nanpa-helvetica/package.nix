{
  lib,
  fetchurl,
  nix-update-script,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "nasin-nanpa-helvetica";
  version = "4.0.2";

  src = fetchurl {
    url = "https://github.com/ETBCOR/nasin-nanpa/releases/download/n${version}/nasin-nanpa-${version}-Helvetica.otf";
    hash = "sha256-isteUDpgdHufXYkcbsC7wbT+e4LzArFe42Tw9wfj04E=";
  };

  installPhase = ''
    mkdir -p $out/share/fonts/opentype
    cp $src $out/share/fonts/opentype/nasin-nanpa-helvetica.otf
  '';

  dontUnpack = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = ''UCSUR OpenType monospaced font for the Toki Pona writing system, Sitelen Pona ("Discord" version; makes UCSUR visible in vanilla Discord)'';

    longDescription = ''
      ni li nasin pi sitelen pona.
      sitelen ale pi nasin ni li sama mute weka.
      sitelen pi nasin ni li lon nasin UCSUR kin.
    '';

    homepage = "https://github.com/ETBCOR/nasin-nanpa";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ feathecutie ];
    platforms = lib.platforms.all;
  };
}
