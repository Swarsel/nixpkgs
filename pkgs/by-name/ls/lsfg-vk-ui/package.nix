{
  lib,
  fetchFromGitHub,
  gdk-pixbuf,
  glib,
  gtk4,
  libadwaita,
  pango,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "lsfg-vk-ui";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "PancakeTAS";
    repo = "lsfg-vk";
    tag = "v${finalAttrs.version}";
    hash = "sha256-nIyVOil/gHC+5a+sH3vMlcqVhixjJaGWqXbyoh2Nqyw=";
  };

  nativeBuildInputs = [
    pkg-config
    glib
  ];

  buildInputs = [
    pango
    gdk-pixbuf
    gtk4
    libadwaita
  ];

  cargoHash = "sha256-hIQRS/egIDU5Vu/1KWHtpt4S26h+9GadVr+lBAG2LDg=";

  postInstall = ''
    install -Dm444 $src/ui/rsc/gay.pancake.lsfg-vk-ui.desktop $out/share/applications/gay.pancake.lsfg-vk-ui.desktop
    install -Dm444 $src/ui/rsc/icon.png $out/share/icons/hicolor/256x256/apps/gay.pancake.lsfg-vk-ui.png
  '';

  sourceRoot = "source/ui";

  meta = {
    description = "Graphical configuration interface for lsfg-vk";
    homepage = "https://github.com/PancakeTAS/lsfg-vk/";
    changelog = "https://github.com/PancakeTAS/lsfg-vk/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pabloaul ];
    platforms = lib.platforms.linux;
    mainProgram = "lsfg-vk-ui";
  };
})
