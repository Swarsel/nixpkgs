{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tie";
  version = "2.4";

  src = fetchurl {
    url = "https://mirrors.ctan.org/web/tie/tie-${finalAttrs.version}.tar.gz";
    sha256 = "1m5952kdfffiz33p1jw0wv7dh272mmw28mpxw9v7lkb352zv4xsj";
  };

  buildPhase = ''
    ${stdenv.cc.targetPrefix}cc -std=c89 tie.c -o tie
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp tie $out/bin
  '';

  meta = {
    description = "Allow multiple web change files";
    homepage = "https://www.ctan.org/tex-archive/web/tie";
    license = lib.licenses.abstyles;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "tie";
  };
})
