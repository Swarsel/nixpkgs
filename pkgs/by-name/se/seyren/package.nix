{
  lib,
  stdenv,
  fetchurl,
  jre,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "seyren";
  version = "1.5.0";

  src = fetchurl {
    url = "https://github.com/scobal/seyren/releases/download/${finalAttrs.version}/seyren-${finalAttrs.version}.jar";
    sha256 = "1fixij04n8hgmaj8kw8i6vclwyd6n94x0n6ify73ynm6dfv8g37x";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ jre ];

  installPhase = ''
    mkdir -p "$out"/bin
    makeWrapper "${jre}/bin/java" "$out"/bin/seyren --add-flags "-jar $src"
  '';

  dontUnpack = true;

  meta = {
    description = "Alerting dashboard for Graphite";
    homepage = "https://github.com/scobal/seyren";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "seyren";
  };
})
