{
  lib,
  stdenv,
  copyDesktopItems,
  fetchzip,
  glib,
  jre,
  makeDesktopItem,
  makeWrapper,
  versionCheckHook,
  wrapGAppsHook3,
}:

stdenv.mkDerivation rec {
  pname = "VASSAL";
  version = "3.7.20";

  src = fetchzip {
    url = "https://github.com/vassalengine/vassal/releases/download/${version}/${pname}-${version}-linux.tar.bz2";
    sha256 = "sha256-aPJgZGRbP016w8riqIVOYnH90QvRs4hnsEdbCVJmLZc=";
  };

  nativeBuildInputs = [
    makeWrapper
    wrapGAppsHook3
    copyDesktopItems
  ];

  buildInputs = [
    glib
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/vassal $out/doc

    cp CHANGES LICENSE README.md $out
    cp -R lib/* $out/share/vassal
    cp -R doc/* $out/doc

    makeWrapper ${jre}/bin/java $out/bin/vassal \
      --add-flags "-Duser.dir=$out -cp $out/share/vassal/Vengine.jar \
      VASSAL.launch.ModuleManager"

    install -Dm444 -t "$out/share/icons/hicolor/scalable/apps/" VASSAL.svg

    runHook postInstall
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Game" ];
      comment = "The open-source boardgame engine";
      desktopName = "VASSAL";
      exec = "vassal";
      icon = "VASSAL";
      name = "VASSAL";
      startupWMClass = "VASSAL-launch-ModuleManager";
    })
  ];

  # Don't move doc to share/, VASSAL expects it to be in the root
  forceShare = [
    "man"
    "info"
  ];

  versionCheckProgram = "${placeholder "out"}/bin/vassal";

  meta = {
    description = "Free, open-source boardgame engine";
    homepage = "https://vassalengine.org/";
    license = lib.licenses.lgpl21Only;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = with lib.maintainers; [ tvestelind ];
    platforms = with lib.platforms; unix ++ windows;
    mainProgram = "vassal";
  };
}
