{ stdenv, fetchurl }:

stdenv.mkDerivation (finalAttrs: {
  pname = "apache-felix-remoteshell-bundle";
  version = "1.1.2";

  src = fetchurl {
    url = "http://apache.proserve.nl/felix/org.apache.felix.shell.remote-${finalAttrs.version}.jar";
    sha256 = "147zw5ppn98wfl3pr32isyb267xm3gwsvdfdvjr33m9g2v1z69aq";
  };

  buildCommand = ''
    mkdir -p $out/bundle
    cp ${finalAttrs.src} $out/bundle/org.apache.felix.shell.remote-${finalAttrs.version}.jar
  '';
})
