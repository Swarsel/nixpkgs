{
  lib,
  stdenv,
  fetchFromGitHub,
  ant,
  copyDesktopItems,
  imagemagick,
  jdk,
  makeDesktopItem,
  makeWrapper,
  stripJavaArchivesHook,
  wrapGAppsHook3,
}:
let
  jdk' = jdk.override { enableJavaFX = true; };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "pattypan";
  version = "22.03";

  src = fetchFromGitHub {
    owner = "yarl";
    repo = "pattypan";
    rev = "v${finalAttrs.version}";
    hash = "sha256-wMQrBg+rEV1W7NgtWFXZr3pAxpyqdbEBKLNwDDGju2I=";
  };

  nativeBuildInputs = [
    ant
    jdk'
    makeWrapper
    wrapGAppsHook3
    copyDesktopItems
    stripJavaArchivesHook
    imagemagick
  ];

  env.JAVA_TOOL_OPTIONS = "-Dfile.encoding=UTF8"; # needed for jdk versions below jdk19

  buildPhase = ''
    runHook preBuild
    ant
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/icons/hicolor/96x96/apps
    install -Dm644 pattypan.jar -t $out/share/pattypan
    magick src/pattypan/resources/logo.png -resize 96x96 $out/share/icons/hicolor/96x96/apps/pattypan.png
    runHook postInstall
  '';

  # gappsWrapperArgs is set in preFixup
  postFixup = ''
    makeWrapper ${jdk'}/bin/java $out/bin/pattypan \
        ''${gappsWrapperArgs[@]} \
        --add-flags "-jar $out/share/pattypan/pattypan.jar"
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Utility" ];
      desktopName = "Pattypan";
      exec = "pattypan";
      genericName = "An uploader for Wikimedia Commons";
      icon = "pattypan";
      name = "pattypan";
    })
  ];

  dontWrapGApps = true;

  meta = {
    description = "Uploader for Wikimedia Commons";
    homepage = "https://commons.wikimedia.org/wiki/Commons:Pattypan";
    license = lib.licenses.mit;

    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode # source bundles dependencies as jars
    ];

    maintainers = with lib.maintainers; [ fee1-dead ];
    platforms = lib.platforms.all;
    mainProgram = "pattypan";
  };
})
