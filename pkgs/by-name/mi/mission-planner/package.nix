{
  lib,
  stdenv,
  fetchurl,
  gitUpdater,
  makeDesktopItem,
  makeWrapper,
  mono,
  unzip,
}:

let
  pname = "mission-planner";
  desktopItem = makeDesktopItem {
    comment = "MissionPlanner GCS & Ardupilot configuration tool";
    desktopName = "MissionPlanner";
    exec = pname;
    genericName = "Ground Control Station";
    icon = pname;
    name = pname;
  };
in
stdenv.mkDerivation rec {
  inherit pname;
  version = "1.3.83";

  src = fetchurl {
    url = "https://firmware.ardupilot.org/Tools/MissionPlanner/MissionPlanner-${version}.zip";
    sha256 = "sha256-/zaU96kDjK91ZUUEndeu9049DY/jWG6HqogQRXBN1vk=";
  };

  nativeBuildInputs = [
    makeWrapper
    mono
    unzip
  ];

  env.AOT_FILES = toString [
    "MissionPlanner.exe"
    "MissionPlanner.*.dll"
  ];

  buildPhase = ''
    runHook preBuild
    for file in $AOT_FILES
    do
      mono --aot $file
    done
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/{bin,opt/mission-planner}
    install -m 444 -D mpdesktop150.png $out/share/icons/mission-planner.png
    cp -r ${desktopItem}/share/applications $out/share/
    mv * $out/opt/mission-planner
    makeWrapper ${mono}/bin/mono $out/bin/mission-planner \
      --add-flags $out/opt/mission-planner/MissionPlanner.exe
    runHook postInstall
  '';

  # zip has no outer directory, so make one and unpack there
  unpackPhase = ''
    runHook preUnpack

    mkdir -p source
    cd source
    unzip -q $src

    runHook postUnpack
  '';

  meta = {
    description = "ArduPilot ground station";

    longDescription = ''
      Full-featured ground station application for the ArduPilot open source
      autopilot project.  Lets you both flash, configure and control ArduPilot
      Plane, Copter and Rover targets.
    '';

    homepage = "https://ardupilot.org/planner/";
    license = lib.licenses.gpl3Plus;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = with lib.maintainers; [ wucke13 ];
    platforms = lib.platforms.all;
    mainProgram = "mission-planner";
  };
}
