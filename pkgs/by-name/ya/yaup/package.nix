{
  lib,
  stdenv,
  fetchFromGitHub,
  copyDesktopItems,
  gtk3,
  intltool,
  makeDesktopItem,
  miniupnpc,
  pkg-config,
  wrapGAppsHook3,
}:

stdenv.mkDerivation {
  pname = "yaup";
  version = "0-unstable-2026-03-25";

  src = fetchFromGitHub {
    owner = "Holarse-Linuxgaming";
    repo = "yaup";
    rev = "7135987a17208dab1b980ba5de55114abe217b63";
    hash = "sha256-1P95cbGy8H+iXs/i7B4eTDzOPXJUJVBTOECsUZX9wG4=";
  };

  postPatch = lib.optionalString stdenv.hostPlatform.isDarwin ''
    # Replace GNU ld's --export-dynamic with macOS linker equivalent
    substituteInPlace src/Makefile.in \
      --replace-fail '-Wl,--export-dynamic' '-Wl,-export_dynamic'
  '';

  nativeBuildInputs = [
    copyDesktopItems
    intltool
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    miniupnpc
  ];

  postInstall = ''
    install -Dm644 src/yaup-dark.png $out/share/icons/hicolor/512x512/apps/yaup.png
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Network"
        "Utility"
      ];

      comment = "Yet Another UPnP Portmapper";
      desktopName = "Yaup";
      exec = "yaup";
      genericName = "UPnP Portmapper";
      icon = "yaup";

      keywords = [
        "Port forwarding"
      ];

      name = "yaup";
    })
  ];

  meta = {
    description = "Yet Another UPnP Portmapper";

    longDescription = ''
      Portmapping made easy.
      Portforward your incoming traffic to a specified local ip.
      Mostly used for IPv4.
    '';

    homepage = "https://github.com/Holarse-Linuxgaming/yaup";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ fgaz ];
    platforms = lib.platforms.all;
    mainProgram = "yaup";
  };
}
