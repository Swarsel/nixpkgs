{
  lib,
  stdenv,
  fetchzip,
  jre,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "epubcheck";
  version = "5.3.0";

  src = fetchzip {
    url = "https://github.com/w3c/epubcheck/releases/download/v${finalAttrs.version}/epubcheck-${finalAttrs.version}.zip";
    sha256 = "sha256-wROsu/s0EuNQQsbMtxWVIwDZvDozBk/kfwxhivCIRAo=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/lib
    cp -r lib/* $out/lib

    mkdir -p $out/libexec/epubcheck
    cp epubcheck.jar $out/libexec/epubcheck

    classpath=$out/libexec/epubcheck/epubcheck.jar
    for jar in $out/lib/*.jar; do
      classpath="$classpath:$jar"
    done

    mkdir -p $out/bin
    makeWrapper ${jre}/bin/java $out/bin/epubcheck \
      --add-flags "-classpath $classpath com.adobe.epubcheck.tool.Checker"
  '';

  dontBuild = true;

  meta = {
    description = "Validation tool for EPUB";
    homepage = "https://github.com/w3c/epubcheck";

    license = with lib.licenses; [
      asl20
      bsd3
      mpl10
      w3c
    ];

    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = with lib.maintainers; [ eadwu ];
    platforms = lib.platforms.all;
    mainProgram = "epubcheck";
  };
})
