{
  lib,
  stdenv,
  ant,
  fetchzip,
  jdk,
  makeWrapper,
  stripJavaArchivesHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "calcoo";
  version = "2.1.0";

  src = fetchzip {
    url = "mirror://sourceforge/calcoo/calcoo-${finalAttrs.version}.zip";
    hash = "sha256-Bdavj7RaI5CkWiOJY+TPRIRfNelfW5qdl/74J1KZPI0=";
  };

  nativeBuildInputs = [
    ant
    stripJavaArchivesHook
    jdk
    makeWrapper
  ];

  env.JAVA_TOOL_OPTIONS = "-Dfile.encoding=iso-8859-1";

  buildPhase = ''
    runHook preBuild
    ant
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 dist/lib/calcoo.jar -t $out/share/calcoo

    makeWrapper ${jdk}/bin/java $out/bin/calcoo \
        --add-flags "-jar $out/share/calcoo/calcoo.jar"

    runHook postInstall
  '';

  dontConfigure = true;

  meta = {
    inherit (jdk.meta) platforms;
    description = "RPN and algebraic scientific calculator";
    homepage = "https://calcoo.sourceforge.net/";
    changelog = "https://calcoo.sourceforge.net/changelog.html";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    mainProgram = "calcoo";
  };
})
