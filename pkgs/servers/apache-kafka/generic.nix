{
  hash,
  kafkaVersion,
  scalaVersion,
}:

{
  lib,
  stdenv,
  fetchurl,
  bash,
  coreutils,
  gnugrep,
  gnused,
  jdk17_headless,
  makeWrapper,
  nixosTests,
  ps,
}:

let
  jre = jdk17_headless;
  series = lib.replaceStrings [ "." ] [ "_" ] (lib.versions.majorMinor kafkaVersion);
  seriesFile = ./. + "/${series}.nix";
in
stdenv.mkDerivation rec {
  pname = "apache-kafka";
  version = "${scalaVersion}-${kafkaVersion}";

  src = fetchurl {
    inherit hash;
    url = "mirror://apache/kafka/${kafkaVersion}/kafka_${version}.tgz";
  };

  strictDeps = true;
  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    jre
    bash
    gnugrep
    gnused
    coreutils
    ps
  ];

  installPhase = ''
    mkdir -p $out
    cp -R config libs $out

    mkdir -p $out/bin
    cp bin/kafka* $out/bin
    cp bin/connect* $out/bin

    # allow us the specify logging directory using env
    substituteInPlace $out/bin/kafka-run-class.sh \
      --replace 'LOG_DIR="$base_dir/logs"' 'LOG_DIR="$KAFKA_LOG_DIR"'

    substituteInPlace $out/bin/kafka-server-stop.sh \
      --replace 'ps' '${ps}/bin/ps'

    for p in $out/bin\/*.sh; do
      wrapProgram $p \
        --set JAVA_HOME "${jre}" \
        --set KAFKA_LOG_DIR "/tmp/apache-kafka-logs" \
        --prefix PATH : "${bash}/bin:${coreutils}/bin:${gnugrep}/bin:${gnused}/bin"
    done
    chmod +x $out/bin\/*
  '';

  __structuredAttrs = true;

  passthru = {
    inherit jre; # Used by the NixOS module to select the supported JRE
    tests.nixos = nixosTests.kafka.base.${"kafka_" + series};

    updateScript = [
      ./update.sh
      seriesFile
    ];
  };

  meta = {
    description = "High-throughput distributed messaging system";
    homepage = "https://kafka.apache.org";
    license = lib.licenses.asl20;
    sourceProvenance = [ lib.sourceTypes.binaryBytecode ];
    maintainers = [ lib.maintainers.ragge ];
    platforms = lib.platforms.unix;
  };
}
