{
  lib,
  fetchFromGitHub,
  cairo,
  gdk-pixbuf,
  glib,
  gobject-introspection,
  graphene,
  gst_all_1,
  gtk4,
  gtk4-layer-shell,
  nix-update-script,
  pango,
  pkg-config,
  poppler,
  protobuf,
  rustPlatform,
  wrapGAppsHook4,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "walker";
  version = "2.16.2";

  src = fetchFromGitHub {
    owner = "abenz1267";
    repo = "walker";
    rev = "v${finalAttrs.version}";
    hash = "sha256-fX3ErzTmHRO9z1SzHC2VZUgKOgRfO13X/joC5a3QN7Q=";
  };

  nativeBuildInputs = [
    gobject-introspection
    pkg-config
    protobuf
    wrapGAppsHook4
  ];

  buildInputs = [
    glib
    gtk4
    gtk4-layer-shell
    gdk-pixbuf
    graphene
    cairo
    pango
    poppler
  ]
  ++ (with gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-libav
  ]);

  cargoHash = "sha256-gm7xQ7qHui8F+uJBWKh7Fen0Zfi/YqpbdgNSoqar0wA=";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Wayland-native application runner";
    homepage = "https://github.com/abenz1267/walker";
    changelog = "https://github.com/abenz1267/walker/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      adamcstephens
      donovanglover
      saadndm
    ];

    platforms = lib.platforms.linux;
    mainProgram = "walker";
  };
})
