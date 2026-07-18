{
  lib,
  stdenv,
  fetchurl,
  commons-daemon,
  jdk,
  jre,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "jsvc";
  version = "1.5.1";

  src = fetchurl {
    url = "mirror://apache/commons/daemon/source/commons-daemon-${finalAttrs.version}-src.tar.gz";
    hash = "sha256-SPnE5jrw1zAy7vIzGrjp0+B4SwCLoufLef3XUcUgK6Y=";
  };

  nativeBuildInputs = [
    jdk
    makeWrapper
  ];

  buildInputs = [ commons-daemon ];
  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.cc.isGNU "-std=gnu17";

  preConfigure = ''
    cd ./src/native/unix/
    sh ./support/buildconf.sh
  '';

  preBuild = ''
    export JAVA_HOME=${jre}
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp jsvc $out/bin/jsvc
    chmod +x $out/bin/jsvc
    wrapProgram $out/bin/jsvc --set JAVA_HOME "${jre}"
    runHook postInstall
  '';

  meta = {
    description = "Part of the Apache Commons Daemon software, a set of utilities and Java support classes for running Java applications as server processes";
    homepage = "https://commons.apache.org/proper/commons-daemon";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ rsynnest ];
    platforms = with lib.platforms; unix;
    mainProgram = "jsvc";
  };
})
