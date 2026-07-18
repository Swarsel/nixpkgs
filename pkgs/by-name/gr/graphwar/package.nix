{
  lib,
  stdenv,
  fetchFromGitHub,
  copyDesktopItems,
  jdk,
  makeDesktopItem,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "graphwar";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "catabriga";
    repo = "graphwar";
    rev = finalAttrs.version;
    sha256 = "sha256-t3Y576dXWp2Mj6OSQN5cm9FuNBWNqKq6xxkVRbjIBgE=";
  };

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
  ];

  buildInputs = [ jdk ];

  buildPhase = ''
    runHook preBuild

    mkdir -p out/
    javac -d out/ -sourcepath src/ -classpath out/ -encoding utf8 src/**/*.java

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/
    mv out $out/lib/graphwar
    cp -r rsc $out/lib/graphwar/rsc

    makeWrapper ${jdk}/bin/java $out/bin/graphwar \
      --add-flags "-classpath $out/lib/graphwar Graphwar.Graphwar"
    makeWrapper ${jdk}/bin/java $out/bin/graphwar-roomserver \
      --add-flags "-classpath $out/lib/graphwar RoomServer.RoomServer"
    makeWrapper ${jdk}/bin/java $out/bin/graphwar-globalserver \
      --add-flags "-classpath $out/lib/graphwar GlobalServer.GlobalServer"

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Game" ];
      desktopName = "Graphwar";
      exec = "graphwar";
      name = "graphwar";
    })
  ];

  meta = {
    description = "Artillery game in which you must hit your enemies using mathematical functions";
    homepage = "https://www.graphwar.com/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ yrd ];
    platforms = jdk.meta.platforms;
  };
})
