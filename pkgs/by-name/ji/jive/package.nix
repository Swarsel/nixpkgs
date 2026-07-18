{
  lib,
  stdenv,
  fetchurl,
  jre,
  makeWrapper,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "jive";
  version = "7.46";

  src = fetchurl {
    url = "https://repo.maven.apache.org/maven2/org/tango-controls/Jive/${finalAttrs.version}/Jive-${finalAttrs.version}-jar-with-dependencies.jar";
    hash = "sha256-AbxTRFi5dCsN/HENTI/o3hBQKZM+cFtJxT3A8RKpQM4=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/java
    cp $src $out/share/java/jive.jar
    makeWrapper ${jre}/bin/java $out/bin/jive \
      --add-flags "-classpath $out/share/java/jive.jar jive3.MainPanel"

    runHook postInstall
  '';

  dontUnpack = true;

  meta = {
    description = "Standalone JAVA application designed to browse and edit the static TANGO database";
    homepage = "https://gitlab.com/tango-controls/jive";
    license = lib.licenses.gpl3;
    sourceProvenance = [ lib.sourceTypes.binaryBytecode ];
    maintainers = [ lib.maintainers.gilice ];
    platforms = lib.platforms.unix;
  };
})
