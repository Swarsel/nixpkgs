{
  lib,
  stdenv,
  fetchurl,
  hunspell,
  ncurses,
  perl,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mythes";
  version = "1.2.4";

  src = fetchurl {
    url = "mirror://sourceforge/hunspell/mythes-${finalAttrs.version}.tar.gz";
    sha256 = "0prh19wy1c74kmzkkavm9qslk99gz8h8wmjvwzjc6lf8v2az708y";
  };

  nativeBuildInputs = [
    ncurses
    pkg-config
    perl
  ];

  buildInputs = [ hunspell ];

  meta = {
    inherit (hunspell.meta) platforms;
    description = "Thesaurus library from Hunspell project";
    homepage = "https://hunspell.sourceforge.net/";
    license = lib.licenses.bsd3;
    mainProgram = "th_gen_idx.pl";
  };
})
