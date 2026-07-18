{
  lib,
  stdenv,
  fetchurl,
  jdk,
  makeWrapper,
  nixosTests,
  writeText,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "soapui";
  version = "5.9.1";

  src = fetchurl {
    url = "https://dl.eviware.com/soapuios/${finalAttrs.version}/SoapUI-${finalAttrs.version}-linux-bin.tar.gz";
    sha256 = "sha256-VlI6TcesavKOpKf/R8S6IubepkthArFf8Jmi7YUGHjs=";
  };

  patches = [
    # Adjust java path to point to derivation paths
    (writeText "soapui-${finalAttrs.version}.patch" ''
      --- a/bin/soapui.sh
      +++ b/bin/soapui.sh
      @@ -50,7 +50,7 @@
       #JAVA 16
       JAVA_OPTS="$JAVA_OPTS --illegal-access=permit"

      -JFXRTPATH=`java -cp $SOAPUI_CLASSPATH com.eviware.soapui.tools.JfxrtLocator`
      +JFXRTPATH=`${jdk}/bin/java -cp $SOAPUI_CLASSPATH com.eviware.soapui.tools.JfxrtLocator`
       SOAPUI_CLASSPATH=$JFXRTPATH:$SOAPUI_CLASSPATH

       if $darwin
      @@ -85,4 +85,4 @@
       echo =
       echo ================================

      -java $JAVA_OPTS -cp $SOAPUI_CLASSPATH com.eviware.soapui.SoapUI "$@"
      +${jdk}/bin/java $JAVA_OPTS -cp $SOAPUI_CLASSPATH com.eviware.soapui.SoapUI "$@"
    '')
  ];

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ jdk ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/java
    cp -R bin lib $out/share/java

    makeWrapper $out/share/java/bin/soapui.sh $out/bin/soapui --set SOAPUI_HOME $out/share/java

    runHook postInstall
  '';

  passthru.tests = { inherit (nixosTests) soapui; };

  meta = {
    description = "Most Advanced REST & SOAP Testing Tool in the World";
    homepage = "https://www.soapui.org/";
    license = lib.licenses.eupl11;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = with lib.maintainers; [ gerschtli ];
    platforms = lib.platforms.linux; # we don't fetch the dmg yet
    mainProgram = "soapui";
  };
})
