{
  lib,
  stdenv,
  fetchurl,
  apr,
  jdk,
  openssl,
}:

stdenv.mkDerivation rec {
  pname = "tomcat-native";
  version = "2.0.15";

  src = fetchurl {
    url = "mirror://apache/tomcat/tomcat-connectors/native/${version}/source/${pname}-${version}-src.tar.gz";
    hash = "sha256-jasJ8hrVGcnknlKH+NjeibsXal45aEefJ5SMMbKjtrQ=";
  };

  buildInputs = [
    apr
    jdk
    openssl
  ];

  configureFlags = [
    "--with-apr=${apr.dev}"
    "--with-java-home=${jdk}"
    "--with-ssl=${openssl.dev}"
  ];

  sourceRoot = "${pname}-${version}-src/native";

  meta = {
    description = "Optional component for use with Apache Tomcat that allows Tomcat to use certain native resources for performance, compatibility, etc";
    homepage = "https://tomcat.apache.org/native-doc/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ aanderse ];
    platforms = lib.platforms.unix;
  };
}
