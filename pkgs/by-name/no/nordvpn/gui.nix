{
  lib,
  copyDesktopItems,
  desktopItemArgs,
  flutter,
  libx11,
  makeDesktopItem,
  meta,
  src,
  version,
}:
flutter.buildFlutterApplication {
  inherit src version;
  pname = "nordvpn-gui";
  # finds X11 using pkg-config
  patches = [ ./linux-cmake.patch ];

  nativeBuildInputs = [
    copyDesktopItems
  ];

  buildInputs = [
    libx11
  ];

  desktopItems = [
    (makeDesktopItem (
      desktopItemArgs
      // {
        comment = "NordVPN's GUI to manage vpn connection, settings, etc.";
        desktopName = "NordVPN GUI";
        exec = "nordvpn-gui";
        name = "nordvpn-gui";
      }
    ))
  ];

  pubspecLock = lib.importJSON ./pubspec.lock.json;
  sourceRoot = "${src.name}/gui";

  meta = meta // {
    description = "NordVPN graphical interface";
    mainProgram = "nordvpn-gui";
  };
}
