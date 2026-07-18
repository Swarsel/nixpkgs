{
  lib,
  fetchzip,
  makeBinaryWrapper,
  makeDesktopItem,
  openjdk21,
  openjfx21,
  stdenvNoCC,
  wrapGAppsHook3,
}:

let
  openjfx_jdk = openjfx21.override { withWebKit = true; };
  openjdk = openjdk21.override {
    inherit openjfx_jdk;
    enableJavaFX = true;
  };

  jvmArgs = [
    "-cp $out/share/minion/lib"
    "--add-exports=javafx.graphics/com.sun.javafx.css=ALL-UNNAMED"
    "--add-exports=javafx.graphics/javafx.scene.image=ALL-UNNAMED"
    "--add-opens=javafx.graphics/javafx.scene.image=ALL-UNNAMED"
    "--add-opens=java.base/java.lang=ALL-UNNAMED"
  ];
in
stdenvNoCC.mkDerivation rec {
  pname = "minion";
  version = "3.0.12";

  src = fetchzip {
    url = "https://cdn.mmoui.com/minion/v3/Minion${version}-java.zip";
    hash = "sha256-KjSj3TBMY3y5kgIywtIDeil0L17dau/Rb2HuXAulSO8=";
    stripRoot = false;
  };

  nativeBuildInputs = [
    makeBinaryWrapper
    wrapGAppsHook3
  ];

  installPhase = ''
    runHook preInstall

    install -D Minion-jfx.jar "$out/share/minion/Minion-jfx.jar"
    cp -r ./lib "$out/share/minion/"

    makeWrapper ${lib.getExe openjdk} $out/bin/minion \
      "''${gappsWrapperArgs[@]}" \
      --add-flags "${lib.concatStringsSep " " jvmArgs} -jar $out/share/minion/Minion-jfx.jar"

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Game" ];
      comment = "MMO Addon manager for Elder Scrolls Online and World of Warcraft";
      desktopName = "Minion";
      exec = "minion";
      name = "minion";
    })
  ];

  dontWrapGApps = true;

  meta = {
    description = "Addon manager for World of Warcraft and The Elder Scrolls Online";
    homepage = "https://minion.mmoui.com/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = with lib.maintainers; [ patrickdag ];
    platforms = lib.platforms.linux;
    mainProgram = "minion";
  };
}
