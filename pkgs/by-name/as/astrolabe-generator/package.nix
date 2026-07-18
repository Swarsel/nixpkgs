{
  lib,
  stdenv,
  fetchurl,
  jre,
  makeWrapper,
  unzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "astrolabe-generator";
  version = "3.3";

  src = fetchurl {
    url = "https://github.com/wymarc/astrolabe-generator/releases/download/v${finalAttrs.version}/AstrolabeGenerator-${finalAttrs.version}.zip";
    hash = "sha256-yTYiUEjxlfZbFNSxvF56LlUPL3kRH6QVFq4GhXN1L5A=";
  };

  nativeBuildInputs = [
    makeWrapper
    unzip
  ];

  buildInputs = [ jre ];

  installPhase = ''
    mkdir -p $out/{bin,share/java}
    cp AstrolabeGenerator-${finalAttrs.version}.jar $out/share/java

    makeWrapper ${jre}/bin/java $out/bin/AstrolabeGenerator \
      --add-flags "-jar $out/share/java/AstrolabeGenerator-${finalAttrs.version}.jar"
  '';

  sourceRoot = ".";

  meta = {
    description = "Java-based tool for generating EPS files for constructing astrolabes and related tools";
    homepage = "https://www.astrolabeproject.com";
    license = lib.licenses.gpl3;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "AstrolabeGenerator";
  };
})
