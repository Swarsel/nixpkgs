{
  lib,
  stdenv,
  fetchurl,
  jdk8,
  jre8,
  makeBinaryWrapper,
  python3Packages,
  runCommand,
  writeText,
}:
let
  jre = jre8; # TODO: remove override https://github.com/NixOS/nixpkgs/pull/89731
  jdk = jdk8; # TODO: remove override https://github.com/NixOS/nixpkgs/pull/89731
in
stdenv.mkDerivation (finalAttrs: {
  pname = "elasticmq-server";
  version = "1.7.1";

  src = fetchurl {
    url = "https://s3-eu-west-1.amazonaws.com/softwaremill-public/elasticmq-server-${finalAttrs.version}.jar";
    sha256 = "sha256-pA39A/2OLxdBjzxhpGDB2uqQIRkUW9zpfQmoHwOqBCg=";
  };

  nativeBuildInputs = [ makeBinaryWrapper ];

  installPhase = ''
    mkdir -p $out/bin $out/share/elasticmq-server

    cp $src $out/share/elasticmq-server/elasticmq-server.jar

    # TODO: how to add extraArgs? current workaround is to use JAVA_TOOL_OPTIONS environment to specify properties
    makeWrapper ${jre}/bin/java $out/bin/elasticmq-server \
      --add-flags "-jar $out/share/elasticmq-server/elasticmq-server.jar"
  '';

  # don't do anything?
  unpackPhase = "${jdk}/bin/jar xf $src favicon.png";

  passthru.tests.elasticmqTest = import ./elasticmq-test.nix {
    inherit runCommand python3Packages writeText;
    elasticmq-server = finalAttrs.finalPackage;
  };

  meta = {
    description = "Message queueing system with Java, Scala and Amazon SQS-compatible interfaces";
    homepage = "https://github.com/softwaremill/elasticmq";
    changelog = "https://github.com/softwaremill/elasticmq/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    platforms = lib.platforms.unix;
    mainProgram = "elasticmq-server";
  };
})
