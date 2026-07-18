{
  lib,
  stdenv,
  fetchurl,
  jdk,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rascal";
  version = "0.33.8";

  src = fetchurl {
    url = "https://update.rascal-mpl.org/console/rascal-${finalAttrs.version}.jar";
    sha256 = "sha256-8m7+ME0mu9LEMzklkz1CZ9s7ZCMjoA5oreICFSpb4S8=";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ jdk ];

  installPhase = ''
    mkdir -p $out/bin
    makeWrapper ${jdk}/bin/java $out/bin/rascal \
      --add-flags "-jar ${finalAttrs.src}"
  '';

  dontUnpack = true;

  meta = {
    description = "Command-line REPL for the Rascal metaprogramming language";
    homepage = "https://www.rascal-mpl.org/";
    license = lib.licenses.epl10;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "rascal";
  };
})
