{
  lib,
  fetchurl,
  gitUpdater,
  graphviz,
  jre,
  makeBinaryWrapper,
  stdenvNoCC,
  testers,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "plantuml";
  version = "1.2026.3";

  src = fetchurl {
    url = "https://github.com/plantuml/plantuml/releases/download/v${finalAttrs.version}/plantuml-pdf-${finalAttrs.version}.jar";
    hash = "sha256-ElMmvC2H8NRYwcEY5oIqo7fsiKAJBZDNqRFXOv2o5IE=";
  };

  nativeBuildInputs = [
    makeBinaryWrapper
  ];

  doInstallCheck = true;

  buildCommand = ''
    install -Dm644 $src $out/lib/plantuml.jar

    mkdir -p $out/bin
    makeWrapper ${jre}/bin/java $out/bin/plantuml \
      --argv0 plantuml \
      --set GRAPHVIZ_DOT ${graphviz}/bin/dot \
      --add-flags "-jar $out/lib/plantuml.jar"
  '';

  postCheckInstall = ''
    $out/bin/plantuml -help
    $out/bin/plantuml -testdot
  '';

  passthru = {
    tests.version = testers.testVersion {
      command = "plantuml --version";
      package = finalAttrs.finalPackage;
    };

    updateScript = gitUpdater {
      allowedVersions = "^1\\.[0-9\\.]+$";
      rev-prefix = "v";
      url = "https://github.com/plantuml/plantuml.git";
    };
  };

  meta = {
    description = "Draw UML diagrams using a simple and human readable text description";
    homepage = "https://plantuml.com/";
    # "plantuml -license" says GPLv3 or later
    license = lib.licenses.gpl3Plus;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];

    maintainers = with lib.maintainers; [
      bjornfor
      anthonyroussel
    ];

    platforms = lib.platforms.unix;
    mainProgram = "plantuml";
  };
})
