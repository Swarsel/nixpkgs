{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "commons-math";
  version = "3.6.1";

  src = fetchurl {
    url = "mirror://apache/commons/math/binaries/commons-math3-${finalAttrs.version}-bin.tar.gz";
    sha256 = "0x4nx5pngv2n4ga11c1s4w2mf6cwydwkgs7da6wwvcjraw57bhkz";
  };

  installPhase = ''
    tar xf ${finalAttrs.src}
    mkdir -p $out/share/java
    cp *.jar $out/share/java/
  '';

  meta = {
    description = "Library of lightweight, self-contained mathematics and statistics components";
    homepage = "https://commons.apache.org/proper/commons-math/";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = [ ];
    platforms = with lib.platforms; unix;
  };
})
