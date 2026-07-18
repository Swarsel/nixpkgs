{
  lib,
  fetchurl,
  jre,
  makeWrapper,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "rars";
  version = "1.6";

  src = fetchurl {
    url = "https://github.com/TheThirdOne/rars/releases/download/v${version}/rars1_6.jar";
    hash = "sha256-eA9zDrRXsbpgnpaKzMLIt32PksPZ2/MMx/2zz7FOjCQ=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    export JAR=$out/share/java/${pname}/${pname}.jar
    install -D $src $JAR
    makeWrapper ${jre}/bin/java $out/bin/${pname} \
      --add-flags "-jar $JAR"
    runHook postInstall
  '';

  dontUnpack = true;

  meta = {
    description = "RISC-V Assembler and Runtime Simulator";
    homepage = "https://github.com/TheThirdOne/rars";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = with lib.maintainers; [ athas ];
    platforms = lib.platforms.all;
    mainProgram = "rars";
  };
}
