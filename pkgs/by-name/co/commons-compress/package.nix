{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "commons-compress";
  version = "1.28.0";

  src = fetchurl {
    url = "mirror://apache/commons/compress/binaries/commons-compress-${finalAttrs.version}-bin.tar.gz";
    sha256 = "sha256-VfAt77mP79azaGiP4+aY5rg2dUFhr59woL6tv2eza5I=";
  };

  installPhase = ''
    tar xf ${finalAttrs.src}
    mkdir -p $out/share/java
    cp *.jar $out/share/java/
  '';

  meta = {
    description = "Allows manipulation of ar, cpio, Unix dump, tar, zip, gzip, XZ, Pack200, bzip2, 7z, arj, lzma, snappy, DEFLATE and Z files";
    homepage = "https://commons.apache.org/proper/commons-compress";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = [ ];
    platforms = with lib.platforms; unix;
  };
})
