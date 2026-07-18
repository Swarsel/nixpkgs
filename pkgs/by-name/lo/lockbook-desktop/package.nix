{
  lib,
  fetchFromGitHub,
  autoPatchelfHook,
  copyDesktopItems,
  gdk-pixbuf,
  glib,
  gobject-introspection,
  gtk3,
  libxkbcommon,
  makeDesktopItem,
  pkg-config,
  rustPlatform,
  vulkan-loader,
}:
let
  desc = "Private, polished note-taking platform";
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "lockbook-desktop";
  version = "26.7.4";

  src = fetchFromGitHub {
    owner = "lockbook";
    repo = "lockbook";
    tag = finalAttrs.version;
    hash = "sha256-gwpobBTugTTTtd/mWVoyiU0E/NjWCTfMnMF0reWLKrA=";
  };

  nativeBuildInputs = [
    pkg-config
    autoPatchelfHook
    copyDesktopItems
  ];

  buildInputs = [
    gtk3
    glib
    gobject-introspection
    gdk-pixbuf
  ];

  cargoHash = "sha256-EH3uIjz2M+Ytkx/gD0gwslUrDVPvm5+hwOGoDtAdblg=";
  doCheck = false; # there are no cli tests

  postInstall = ''
    install -D docs/graphics/logo.svg $out/share/icons/hicolor/scalable/apps/lockbook.svg
  '';

  cargoBuildFlags = [
    "--package"
    "lockbook-desktop"
  ];

  desktopItems = makeDesktopItem {
    categories = [
      "Office"
      "Documentation"
      "Utility"
    ];

    comment = desc;
    desktopName = "Lockbook";
    exec = "lockbook-desktop";
    icon = "lockbook";
    name = "lockbook-desktop";
  };

  runtimeDependencies = [
    vulkan-loader
    libxkbcommon
  ];

  meta = {
    description = desc;

    longDescription = ''
      Write notes, sketch ideas, and store files in one secure place.
      Share seamlessly, keep data synced, and access it on any
      platform—even offline. Lockbook encrypts files so even we
      can’t see them, but don’t take our word for it:
      Lockbook is 100% open-source.
    '';

    homepage = "https://lockbook.net";
    changelog = "https://github.com/lockbook/lockbook/releases/tag/${finalAttrs.version}";
    license = lib.licenses.unlicense;
    maintainers = [ lib.maintainers.parth ];
    platforms = lib.platforms.linux;
  };
})
