{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "docbook-xml-ebnf";
  version = "1.2b1";

  installPhase = ''
    cp -p $dtd dbebnf.dtd
    cp -p $catalog $(stripHash $catalog)
  '';

  catalog = ./docbook-ebnf.cat;

  dtd = fetchurl {
    sha256 = "0min5dsc53my13b94g2yd65q1nkjcf4x1dak00bsc4ckf86mrx95";
    url = "https://docbook.org/xml/ebnf/${finalAttrs.version}/dbebnf.dtd";
  };

  unpackPhase = ''
    mkdir -p $out/xml/dtd/docbook-ebnf
    cd $out/xml/dtd/docbook-ebnf
  '';

  meta = {
    platforms = lib.platforms.unix;
  };
})
