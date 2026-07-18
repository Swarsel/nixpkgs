{
  lib,
  fetchurl,
  jre,
  makeWrapper,
  rhino,
  stdenvNoCC,
  stripJavaArchivesHook,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "batik";
  version = "1.19";

  src = fetchurl {
    url = "mirror://apache/xmlgraphics/batik/binaries/batik-bin-${finalAttrs.version}.tar.gz";
    hash = "sha256-1KuzhFSEv+GJqA83QZuUx35mvUuLueW/cs5wvIZe2yI=";
  };

  nativeBuildInputs = [
    stripJavaArchivesHook
    makeWrapper
  ];

  buildInputs = [
    jre
    rhino
  ];

  installPhase = ''
    mkdir -p $out/bin $out/share/java
    cp *.jar lib/*.jar $out/share/java
    chmod +x $out/share/java/*.jar
    classpath="$(find $out/share/java -name '*.jar' -printf '${rhino}/share/java/js.jar:%h/%f')"
    for appName in rasterizer slideshow squiggle svgpp ttf2svg; do
      makeWrapper ${lib.getExe jre} $out/bin/batik-$appName \
        --add-flags "-jar $out/share/java/batik-all-${finalAttrs.version}.jar" \
        --add-flags "-classpath $classpath" \
        --add-flags "org.apache.batik.apps.$appName.Main"
    done
  '';

  patchPhase = ''
    # Vendored dependencies
    rm lib/rhino-*.jar
  '';

  meta = {
    description = "Java based toolkit for handling SVG";
    homepage = "https://xmlgraphics.apache.org/batik";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    platforms = lib.platforms.unix;
  };
})
