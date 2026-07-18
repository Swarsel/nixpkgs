{
  lib,
  stdenv,
  fetchurl,
  jdk,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lombok";
  version = "1.18.42";

  src = fetchurl {
    url = "https://projectlombok.org/downloads/lombok-${finalAttrs.version}.jar";
    sha256 = "sha256-NIik6ZlMJllrqs7r7ljK02pQ472uxb5ytYNNPDtWAwY=";
  };

  outputs = [
    "out"
    "bin"
  ];

  nativeBuildInputs = [ makeWrapper ];

  buildCommand = ''
    mkdir -p $out/share/java
    cp $src $out/share/java/lombok.jar

    makeWrapper ${jdk}/bin/java $bin/bin/lombok \
      --add-flags "-cp ${jdk}/lib/openjdk/lib/tools.jar:$out/share/java/lombok.jar" \
      --add-flags lombok.launch.Main
  '';

  meta = {
    description = "Library that can write a lot of boilerplate for your Java project";
    homepage = "https://projectlombok.org/";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = [ lib.maintainers.CrystalGamma ];
    platforms = lib.platforms.all;
    mainProgram = "lombok";
  };
})
