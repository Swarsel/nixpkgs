{
  lib,
  stdenv,
  fetchurl,
  which,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "crunch";
  version = "3.6";

  src = fetchurl {
    url = "mirror://sourceforge/crunch-wordlist/crunch-${finalAttrs.version}.tgz";
    sha256 = "0mgy6ghjvzr26yrhj1bn73qzw6v9qsniskc5wqq1kk0hfhy6r3va";
  };

  nativeBuildInputs = [ which ];

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=$(out)"
  ];

  preBuild = ''
    substituteInPlace Makefile \
      --replace '-g root -o root' "" \
      --replace '-g wheel -o root' "" \
      --replace 'sudo ' ""
  '';

  meta = {
    description = "Wordlist generator";
    homepage = "https://sourceforge.net/projects/crunch-wordlist/";
    license = with lib.licenses; [ gpl2Only ];
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "crunch";
  };
})
