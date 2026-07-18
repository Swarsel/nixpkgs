{
  lib,
  stdenv,
  libice,
  libsm,
  libx11,
  libxpm,
  libxt,
  requireFile,
  unzip,
}:

stdenv.mkDerivation rec {
  pname = "sun-java-wtk";
  version = "2.5.2_01";

  src = requireFile {
    url = "http://java.sun.com/products/sjwtoolkit/download.html";
    sha256 = "1cjb9c27847wv0hq3j645ckn4di4vsfvp29fr4zmdqsnvk4ahvj1";
    name = "sun_java_wireless_toolkit-${version}-linuxi486.bin.sh";
  };

  nativeBuildInputs = [ unzip ];
  builder = ./builder.sh;

  libraries = [
    libxpm
    libxt
    libx11
    libice
    libsm
    stdenv.cc.cc
  ];

  meta = {
    description = "Sun Java Wireless Toolkit 2.5.2_01 for CLDC";
    homepage = "http://java.sun.com/products/sjwtoolkit/download.html";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "i686-linux" ];
  };
}
