{
  lib,
  stdenv,
  fetchurl,
  coreutils,
  gnupg,
  jdk,
  makeWrapper,
  rlwrap,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "leiningen";
  version = "2.12.0";

  src = fetchurl {
    url = "https://codeberg.org/leiningen/leiningen/raw/tag/${finalAttrs.version}/bin/lein-pkg";
    hash = "sha256-EqnF46JHFhnKPWSnRi+SD99xOuiVnrT81iV8IzMrWqQ=";
  };

  nativeBuildInputs = [ makeWrapper ];
  propagatedBuildInputs = [ jdk ];
  env.JARNAME = "leiningen-${finalAttrs.version}-standalone.jar";

  # the jar is not in share/java, because it's a standalone jar and should
  # never be picked up by set-java-classpath.sh
  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share
    cp -v $src $out/bin/lein
    cp -v $jarsrc $out/share/$JARNAME

    runHook postInstall
  '';

  dontUnpack = true;

  fixupPhase = ''
    runHook preFixup

    chmod +x $out/bin/lein
    patchShebangs $out/bin/lein
    substituteInPlace $out/bin/lein \
      --replace-fail 'LEIN_JAR=/usr/share/java/leiningen-$LEIN_VERSION-standalone.jar' "LEIN_JAR=$out/share/$JARNAME"
    wrapProgram $out/bin/lein \
      --prefix PATH ":" "${
        lib.makeBinPath [
          rlwrap
          coreutils
        ]
      }" \
      --set LEIN_GPG ${gnupg}/bin/gpg \
      --set JAVA_CMD ${jdk}/bin/java

    runHook postFixup
  '';

  jarsrc = fetchurl {
    hash = "sha256-tyGlc69jF4TyfMtS5xnm0Sh9nTlRrVbTFtOPfs+oGqI=";
    url = "https://codeberg.org/leiningen/leiningen/releases/download/${finalAttrs.version}/leiningen-${finalAttrs.version}-standalone.jar";
  };

  meta = {
    description = "Project automation for Clojure";
    homepage = "https://leiningen.org/";
    license = lib.licenses.epl10;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = [ ];
    platforms = jdk.meta.platforms;
    mainProgram = "lein";
  };
})
