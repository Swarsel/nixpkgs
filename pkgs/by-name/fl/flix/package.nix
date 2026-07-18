{
  lib,
  fetchurl,
  jre,
  makeWrapper,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "flix";
  version = "0.75.1";

  src = fetchurl {
    url = "https://github.com/flix/flix/releases/download/v${version}/flix.jar";
    sha256 = "sha256-4xd3AK6tiiKkLJEOc7+4oyb+/bq04+rq9tVcMopr2Tg=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    export JAR=$out/share/java/flix/flix.jar
    install -D $src $JAR
    makeWrapper ${jre}/bin/java $out/bin/flix \
      --add-flags "-jar $JAR"

    runHook postInstall
  '';

  dontUnpack = true;

  meta = {
    inherit (jre.meta) platforms;
    description = "Flix Programming Language";
    homepage = "https://github.com/flix/flix";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = with lib.maintainers; [ athas ];
    mainProgram = "flix";
  };
}
