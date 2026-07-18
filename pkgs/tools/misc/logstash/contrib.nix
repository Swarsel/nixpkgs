{
  lib,
  stdenv,
  fetchzip,
}:

# Note that plugins are supposed to be installed as:
#   $path/logstash/{inputs,codecs,filters,outputs}/*.rb
stdenv.mkDerivation rec {
  pname = "logstash-contrib";
  version = "1.4.2";

  src = fetchzip {
    url = "https://download.elasticsearch.org/logstash/logstash/logstash-contrib-${version}.tar.gz";
    sha256 = "1yj8sf3b526gixh3c6zhgkfpg4f0c72p1lzhfhdx8b3lw7zjkj0k";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/logstash
    cp -r lib/* $out
    runHook postInstall
  '';

  dontBuild = true;
  dontPatchELF = true;
  dontPatchShebangs = true;
  dontStrip = true;

  meta = {
    description = "Community-maintained logstash plugins";
    homepage = "https://github.com/elasticsearch/logstash-contrib";
    license = lib.licenses.asl20;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
}
