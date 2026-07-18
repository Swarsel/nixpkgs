{
  lib,
  stdenv,
  fetchFromGitHub,
  ant,
  copyDesktopItems,
  jdk8, # the build script wants JAVA 8 for compilation
  jre, # version can be >= 8 (latest version by default)
  makeDesktopItem,
  makeWrapper,
  stripJavaArchivesHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "jpsxdec";
  version = "2.1";

  src = fetchFromGitHub {
    owner = "m35";
    repo = "jpsxdec";
    rev = "v${finalAttrs.version}";
    hash = "sha256-X55/FKfPLSwl7veB0LOmXeFEh5zJ10zKdTbCUnnyB5g=";
  };

  nativeBuildInputs = [
    ant
    jdk8
    makeWrapper
    copyDesktopItems
    stripJavaArchivesHook
  ];

  buildPhase = ''
    runHook preBuild
    ant release
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/jpsxdec
    mv _ant/release/{doc,*.jar} $out/share/jpsxdec
    install -Dm644 src/jpsxdec/gui/icon16.png $out/share/icons/hicolor/16x16/apps/jpsxdec.png
    install -Dm644 src/jpsxdec/gui/icon32.png $out/share/icons/hicolor/32x32/apps/jpsxdec.png
    install -Dm644 src/jpsxdec/gui/icon48.png $out/share/icons/hicolor/48x48/apps/jpsxdec.png

    makeWrapper ${jre}/bin/java $out/bin/jpsxdec \
        --add-flags "-jar $out/share/jpsxdec/jpsxdec.jar"

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "AudioVideo"
        "Utility"
      ];

      comment = finalAttrs.meta.description;
      desktopName = "jPSXdec";
      exec = "jpsxdec";
      icon = "jpsxdec";
      name = "jpsxdec";
    })
  ];

  sourceRoot = "${finalAttrs.src.name}/jpsxdec";

  meta = {
    description = "Cross-platform PlayStation 1 audio and video converter";
    homepage = "https://jpsxdec.blogspot.com/";
    changelog = "https://github.com/m35/jpsxdec/blob/${finalAttrs.src.rev}/jpsxdec/doc/CHANGES.txt";

    license = {
      free = true;
      url = "https://raw.githubusercontent.com/m35/jpsxdec/${finalAttrs.src.rev}/.github/LICENSE.md";
    };

    maintainers = with lib.maintainers; [ zane ];
    platforms = lib.platforms.all;
    mainProgram = "jpsxdec";
  };
})
