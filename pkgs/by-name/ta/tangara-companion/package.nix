{
  lib,
  fetchFromGitHub,
  copyDesktopItems,
  gdk-pixbuf,
  glib,
  graphene,
  gtk4,
  libadwaita,
  makeDesktopItem,
  pango,
  pkg-config,
  rustPlatform,
  udev,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tangara-companion";
  version = "0.5.2";

  src = fetchFromGitHub {
    owner = "haileys";
    repo = "tangara-companion";
    tag = "v${finalAttrs.version}";
    hash = "sha256-x/xB+itr1GVcaTEre3u6Lchg9VcSzWiNyWVGv5Aczgw=";
  };

  nativeBuildInputs = [
    copyDesktopItems
    glib
    pkg-config
  ];

  buildInputs = [
    gdk-pixbuf
    glib
    graphene
    gtk4
    libadwaita
    pango
    udev
  ];

  cargoHash = "sha256-PVTfAG2AOioW1zVXtXB5SBJX2sJoWVRQO3NafUOAleo=";

  postInstall = ''
    install -Dm644 $src/data/assets/icon.svg $out/share/icons/hicolor/scalable/apps/tangara-companion.svg
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Utility"
        "GTK"
      ];

      comment = finalAttrs.meta.description;
      desktopName = "Tangara Companion";
      exec = finalAttrs.meta.mainProgram;
      icon = "tangara-companion";
      name = "tangara-companion";
      startupNotify = true;
      terminal = false;
      type = "Application";
    })
  ];

  meta = {
    description = "Companion app for Cool Tech Zone Tangara";
    homepage = "https://github.com/haileys/tangara-companion";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ benpye ];
    platforms = lib.platforms.linux;
    mainProgram = "tangara-companion";
  };
})
