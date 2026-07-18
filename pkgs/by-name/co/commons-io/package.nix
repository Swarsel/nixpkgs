{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "commons-io";
  version = "2.22.0";

  src = fetchurl {
    url = "mirror://apache/commons/io/binaries/commons-io-${finalAttrs.version}-bin.tar.gz";
    hash = "sha256-DQ17WESs+TMizYkp7yG103LZdS8i+XqEkfFrlttoTm8=";
  };

  installPhase = ''
    tar xf ${finalAttrs.src}
    mkdir -p $out/share/java
    cp *.jar $out/share/java/
  '';

  meta = {
    description = "Library of utilities to assist with developing IO functionality";
    homepage = "https://commons.apache.org/proper/commons-io";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = [ ];
    platforms = with lib.platforms; unix;
  };
})
