{
  lib,
  stdenv,
  fetchurl,
  copyDesktopItems,
  jre,
  libGL,
  libpulseaudio,
  libxxf86vm,
  makeDesktopItem,
  makeWrapper,
  nix-update-script,
}:
let
  version = "4.20.11";

  desktopItem = makeDesktopItem {
    categories = [ "Game" ];
    comment = "An open-source Android/Desktop remake of Civ V";
    desktopName = "Unciv";
    exec = "unciv";
    icon = "unciv";
    name = "unciv";
  };

  desktopIcon = fetchurl {
    hash = "sha256-Zuz+HGfxjGviGBKTiHdIFXF8UMRLEIfM8f+LIB/xonk=";
    url = "https://github.com/yairm210/Unciv/blob/${version}/extraImages/Icons/Unciv%20icon%20v6.png?raw=true";
  };

  envLibPath = lib.makeLibraryPath (
    lib.optionals stdenv.hostPlatform.isLinux [
      libGL
      libpulseaudio
      libxxf86vm
    ]
  );
in
stdenv.mkDerivation rec {
  inherit version;
  pname = "unciv";

  src = fetchurl {
    url = "https://github.com/yairm210/Unciv/releases/download/${version}/Unciv.jar";
    hash = "sha256-O9A11GJyz6yApD7Nni11TEohT+8hRDG02k6lQWtBHgw=";
  };

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    makeWrapper ${jre}/bin/java $out/bin/unciv \
      --prefix LD_LIBRARY_PATH : "${envLibPath}" \
      --prefix PATH : ${lib.makeBinPath [ jre ]} \
      --add-flags "-jar ${src}"

    install -Dm444 ${desktopIcon} $out/share/icons/hicolor/512x512/apps/unciv.png

    runHook postInstall
  '';

  desktopItems = [ desktopItem ];
  dontUnpack = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Open-source Android/Desktop remake of Civ V";
    homepage = "https://github.com/yairm210/Unciv";
    license = lib.licenses.mpl20;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = with lib.maintainers; [ iedame ];
    platforms = lib.platforms.all;
    mainProgram = "unciv";
  };
}
