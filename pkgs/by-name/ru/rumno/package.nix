{
  lib,
  fetchFromGitLab,
  atk,
  cairo,
  dbus,
  gdk-pixbuf,
  glib,
  gtk-layer-shell,
  gtk3,
  harfbuzz,
  nix-update-script,
  pango,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rumno";
  version = "0.1.3";

  src = fetchFromGitLab {
    owner = "ivanmalison";
    repo = "rumno";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vR6+dNq0sdVtzdBL6GTzqAhl0fE6ulF6UCqIH1fSte4=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    dbus
    gdk-pixbuf
    glib
    gtk3
    cairo
    atk
    pango
    harfbuzz
    gtk-layer-shell
  ];

  cargoHash = "sha256-1FyDMdOO7m6y2oX/+VH5LxBwimz7fXM59eOeiffBnOI=";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Visual pop-up notification manager";
    homepage = "https://gitlab.com/ivanmalison/rumno";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ imalison ];
    platforms = lib.platforms.linux;
    mainProgram = "rumno";
  };
})
