{
  lib,
  fetchFromGitHub,
  glib,
  gtk4,
  hyprland,
  pango,
  pkg-config,
  rustPlatform,
  wrapGAppsHook4,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "hyprviz";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "timasoft";
    repo = "hyprviz";
    tag = "v${finalAttrs.version}";
    hash = "sha256-d1JNCCzCpJw646VrwSdrj175F4w4AsAfvGv4CnCEEv4=";
  };

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk4
    glib
    pango
  ];

  cargoHash = "sha256-Wjk1nqSoqeHvdTRzoRl3NTJIB5Chp14Cm/6weniVwiI=";

  postInstall = ''
    install -Dm644 assets/hyprviz.desktop -t $out/share/applications
    install -Dm644 assets/hyprviz.svg -t $out/share/icons/hicolor/scalable/apps
    install -Dm644 assets/hyprviz.png -t $out/share/icons/hicolor/256x256/apps
  '';

  meta = {
    description = "GUI for configuring Hyprland";
    homepage = "https://github.com/timasoft/hyprviz";
    changelog = "https://github.com/timasoft/hyprviz/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ timasoft ];
    platforms = hyprland.meta.platforms;
    mainProgram = "hyprviz";
  };
})
