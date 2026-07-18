{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  copyDesktopItems,
  libsForQt5,
  makeDesktopItem,
}:

let
  # Based in desktop files from official packages:
  # https://github.com/congard/nvidia-system-monitor-qt/tree/master/package
  desktopItem = makeDesktopItem {
    categories = [
      "System"
      "Utility"
      "Qt"
    ];

    desktopName = "NVIDIA System Monitor";
    exec = "qnvsm";
    icon = "qnvsm";
    name = "nvidia-system-monitor-qt";
  };
in
stdenv.mkDerivation rec {
  pname = "nvidia-system-monitor-qt";
  version = "1.6-1";

  src = fetchFromGitHub {
    owner = "congard";
    repo = "nvidia-system-monitor-qt";
    rev = "v${version}";
    sha256 = "sha256-JHK7idyk5UxgDyt+SzvYjTLmlNzx6+Z+OPYsRD4NWPg=";
  };

  nativeBuildInputs = [
    cmake
    libsForQt5.wrapQtAppsHook
    copyDesktopItems
  ];

  buildInputs = [ libsForQt5.qtbase ];

  cmakeFlags = [
    "-DIconPath=${placeholder "out"}/share/icons/hicolor/512x512/apps/qnvsm.png"
    "-DVersionPrefix=(Nixpkgs)"
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 qnvsm $out/bin/qnvsm
    install -Dm644 $src/icon.png $out/share/icons/hicolor/512x512/apps/qnvsm.png

    runHook postInstall
  '';

  desktopItems = [ desktopItem ];

  meta = rec {
    description = "Task Manager for Linux for NVIDIA graphics cards";
    homepage = "https://github.com/congard/nvidia-system-monitor-qt";
    changelog = "${downloadPage}/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hacker1024 ];
    platforms = lib.platforms.linux;
    mainProgram = "qnvsm";
    downloadPage = "${homepage}/releases";
  };
}
