{
  lib,
  fetchFromGitHub,
  copyDesktopItems,
  gdk-pixbuf,
  glib,
  graphene,
  gtk4,
  makeDesktopItem,
  pango,
  pkg-config,
  rustPlatform,
  wrapGAppsHook4,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "airgorah";
  version = "0.7.4";

  src = fetchFromGitHub {
    owner = "martin-olivier";
    repo = "airgorah";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6TH+DRDtWajZjHNmFSKL4XJK+AuDNUbWKRPRryOpSGY=";
  };

  nativeBuildInputs = [
    pkg-config
    copyDesktopItems
    wrapGAppsHook4
  ];

  buildInputs = [
    glib
    pango
    gdk-pixbuf
    graphene
    gtk4
  ];

  cargoHash = "sha256-LiSaNyqsKBZ5nNP7mws1pjhVwTXNBF6e1wSUdG/qYog=";

  postInstall = ''
    install -Dm644 icons/app_icon.png $out/share/icons/airgorah.png
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Network"
        "Monitor"
        "Utility"
        "GTK"
      ];

      comment = "A WiFi auditing software that can perform deauth attacks and passwords cracking";
      desktopName = "airgorah";
      exec = "pkexec airgorah";
      icon = "airgorah";
      name = "airgorah";
      terminal = false;
      type = "Application";
    })
  ];

  meta = {
    description = "WiFi security auditing software mainly based on aircrack-ng tools suite";
    homepage = "https://github.com/martin-olivier/airgorah";
    changelog = "https://github.com/martin-olivier/airgorah/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bot-wxt1221 ];
    platforms = lib.platforms.linux;
    mainProgram = "airgorah";
  };
})
