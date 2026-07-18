{
  lib,
  stdenv,
  fetchurl,
  jdk,
  runtimeShell,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "polylith";
  version = "0.3.32";

  src = fetchurl {
    url = "https://github.com/polyfy/polylith/releases/download/v${finalAttrs.version}/poly-${finalAttrs.version}.jar";
    sha256 = "sha256-bfF7YXGA6StGF1jZor/TZQ6tNU28Z8kcaiPdkmjljx4=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    printf "%s" "$polyWrapper" > $out/bin/poly
    chmod a+x $out/bin/poly

    runHook postInstall
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck

    $out/bin/poly help | fgrep -q '${finalAttrs.version}'

    runHook postInstallCheck
  '';

  __structuredAttrs = true;
  dontUnpack = true;

  polyWrapper = ''
    #!${runtimeShell}
    ARGS=""
    while [ "$1" != "" ] ; do
      ARGS="$ARGS $1"
      shift
    done
    exec "${jdk}/bin/java" "-jar" "${finalAttrs.src}" $ARGS
  '';

  meta = {
    description = "Tool used to develop Polylith based architectures in Clojure";
    homepage = "https://github.com/polyfy/polylith";
    license = lib.licenses.epl10;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];

    maintainers = with lib.maintainers; [
      ericdallo
      jlesquembre
    ];

    platforms = jdk.meta.platforms;
    mainProgram = "poly";
  };
})
