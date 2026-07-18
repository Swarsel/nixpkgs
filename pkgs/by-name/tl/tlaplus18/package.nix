{
  lib,
  stdenv,
  fetchurl,
  jre,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tlaplus";
  version = "1.8.0";

  src = fetchurl {
    url = "https://github.com/tlaplus/tlaplus/releases/download/v${finalAttrs.version}/tla2tools.jar";
    sha256 = "sha256-OXgpd1xuyvhveunlybBi/N6jnxtp/J8Kmp8PYX3eSZ4=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/share/java $out/bin
    cp $src $out/share/java/tla2tools.jar

    makeWrapper ${jre}/bin/java $out/bin/tlc \
      --add-flags "-XX:+UseParallelGC -cp $out/share/java/tla2tools.jar tlc2.TLC"
    makeWrapper ${jre}/bin/java $out/bin/tlasany \
      --add-flags "-XX:+UseParallelGC -cp $out/share/java/tla2tools.jar tla2sany.SANY"
    makeWrapper ${jre}/bin/java $out/bin/pcal \
      --add-flags "-XX:+UseParallelGC -cp $out/share/java/tla2tools.jar pcal.trans"
    makeWrapper ${jre}/bin/java $out/bin/tlatex \
      --add-flags "-XX:+UseParallelGC -cp $out/share/java/tla2tools.jar tla2tex.TLA"
    makeWrapper ${jre}/bin/java $out/bin/tlarepl \
      --add-flags "-XX:+UseParallelGC -cp $out/share/java/tla2tools.jar tlc2.REPL"
  '';

  dontUnpack = true;

  meta = {
    description = "Algorithm specification language with model checking tools";
    homepage = "https://lamport.azurewebsites.net/tla/tla.html";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];

    maintainers = with lib.maintainers; [
      florentc
      thoughtpolice
      mgregson
    ];

    platforms = lib.platforms.unix;
  };
})
