{
  lib,
  stdenv,
  fetchurl,
  jre,
  makeWrapper,
}:

stdenv.mkDerivation rec {
  pname = "jmx-prometheus-httpserver";
  version = "0.15.0";

  src = fetchurl {
    url = "mirror://maven/io/prometheus/jmx/jmx_prometheus_httpserver/${version}/${jarName}";
    sha256 = "0fr3svn8kjp7bq1wzbkvv5awylwn8b01bngj04zvk7fpzqpgs7mz";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ jre ];

  installPhase = ''
    mkdir -p $out/libexec
    mkdir -p $out/bin
    cp $src $out/libexec/$jarName
    makeWrapper "${jre}/bin/java" $out/bin/jmx_prometheus_httpserver --add-flags "-jar $out/libexec/$jarName"
  '';

  dontUnpack = true;
  jarName = "jmx_prometheus_httpserver-${version}-jar-with-dependencies.jar";

  meta = {
    description = "Process for exposing JMX Beans via HTTP for Prometheus consumption";
    homepage = "https://github.com/prometheus/jmx_exporter";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "jmx_prometheus_httpserver";
  };
}
