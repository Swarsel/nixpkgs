{
  lib,
  stdenv,
  fetchurl,
  jre,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ditaa";
  version = "0.11.0";

  src = fetchurl {
    url = "https://github.com/stathissideris/ditaa/releases/download/v${finalAttrs.version}/ditaa-${finalAttrs.version}-standalone.jar";
    sha256 = "1acnl7khz8aasg230nbsx9dyf8716scgb5l3679cb2bdzxisl64l";
  };

  installPhase = ''
    mkdir -p $out/bin $out/lib

    cp ${finalAttrs.src} "$out/lib/ditaa.jar"

    cat > "$out/bin/ditaa" << EOF
    #!${stdenv.shell}
    exec ${jre}/bin/java -jar "$out/lib/ditaa.jar" "\$@"
    EOF

    chmod a+x "$out/bin/ditaa"
  '';

  dontUnpack = true;

  meta = {
    description = "Convert ascii art diagrams into proper bitmap graphics";
    homepage = "https://github.com/stathissideris/ditaa";
    license = lib.licenses.lgpl3;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = [ lib.maintainers.bjornfor ];
    platforms = lib.platforms.unix;
    mainProgram = "ditaa";
  };
})
