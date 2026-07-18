{
  lib,
  stdenv,
  fetchurl,
  jdk,
  python3,
  testers,
  unzip,
  zip,
  confFile ? "",
  extraJars ? [ ],
  extraLibraryPaths ? [ ],
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "apache-storm";
  version = "2.8.3";

  src = fetchurl {
    url = "mirror://apache/storm/${finalAttrs.name}/${finalAttrs.name}.tar.gz";
    hash = "sha256-W7a/4vJgGhiAxk0l+1jY+38Mpz8WOLodhlW6l6nQHEc=";
  };

  nativeBuildInputs = [
    zip
    unzip
  ];

  installPhase = ''
    mkdir -p $out/share/${finalAttrs.name}
    mv public $out/docs
    mv examples $out/share/${finalAttrs.name}/.

    mv external extlib* lib $out/.
    mv conf bin $out/.
    mv log4j2 $out/conf/.
  '';

  dontStrip = true;

  fixupPhase = ''
    patchShebangs $out
    # Fix python reference
    sed -i \
      -e '19iPYTHON=${python3}/bin/python' \
      -e 's|#!/usr/bin/.*python|#!${python3}/bin/python|' \
      $out/bin/storm
    sed -i \
      -e 's|#!/usr/bin/.*python|#!${python3}/bin/python|' \
      -e "s|STORM_CONF_DIR = .*|STORM_CONF_DIR = os.getenv('STORM_CONF_DIR','$out/conf')|" \
      -e 's|STORM_LOG4J2_CONF_DIR =.*|STORM_LOG4J2_CONF_DIR = os.path.join(STORM_CONF_DIR, "log4j2")|' \
        $out/bin/storm.py

    # Default jdk location
    sed -i -e 's|export JAVA_HOME=.*|export JAVA_HOME="${jdk.home}"|' \
           $out/conf/storm-env.sh
    unzip  $out/lib/storm-client-${finalAttrs.version}.jar defaults.yaml;
    zip -d $out/lib/storm-client-${finalAttrs.version}.jar defaults.yaml;
    sed -i \
       -e 's|java.library.path: .*|java.library.path: "${lib.concatStringsSep ":" extraLibraryPaths}"|' \
       -e 's|storm.log4j2.conf.dir: .*|storm.log4j2.conf.dir: "conf/log4j2"|' \
      defaults.yaml
    ${lib.optionalString (confFile != "") "cat ${confFile} >> defaults.yaml"}
    mv defaults.yaml $out/conf;

    # Link to extra jars
    cd $out/lib;
    ${lib.concatMapStrings (jar: "ln -s ${jar};\n") extraJars}
  '';

  name = "${finalAttrs.pname}-${finalAttrs.version}";

  passthru.tests.version = testers.testVersion {
    command = "storm version";
    package = finalAttrs.finalPackage;
  };

  meta = {
    description = "Distributed realtime computation system";
    homepage = "https://storm.apache.org/";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = [ ];
    platforms = with lib.platforms; unix;
  };
})
