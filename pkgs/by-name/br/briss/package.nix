# The releases of this project are apparently precompiled to .jar files.

{
  lib,
  stdenv,
  fetchurl,
  jre,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "briss";
  version = "0.9";

  src = fetchurl {
    url = "mirror://sourceforge/briss/briss-${finalAttrs.version}.tar.gz";
    sha256 = "45dd668a9ceb9cd59529a9fefe422a002ee1554a61be07e6fc8b3baf33d733d9";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p "$out/bin";
    mkdir -p "$out/share";
    install -D -m444 -t "$out/share" *.jar
    makeWrapper "${jre}/bin/java" "$out/bin/briss" --add-flags "-Xms128m -Xmx1024m -cp \"$out/share/\" -jar \"$out/share/briss-${finalAttrs.version}.jar\""
  '';

  meta = {
    description = "Java application for cropping PDF files";
    homepage = "https://sourceforge.net/projects/briss/";
    license = lib.licenses.gpl3;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    platforms = lib.platforms.unix;
    mainProgram = "briss";
  };
})
