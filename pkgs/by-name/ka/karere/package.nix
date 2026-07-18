{
  lib,
  stdenv,
  fetchFromGitHub,
  blueprint-compiler,
  cargo,
  desktop-file-utils,
  glib-networking,
  gst_all_1,
  libadwaita,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  rustPlatform,
  rustc,
  webkitgtk_6_0,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "karere";
  version = "3.1.1";

  src = fetchFromGitHub {
    owner = "tobagin";
    repo = "karere";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VJGTpkMkYKvU/I/DoyBMD9deciLzmrs48If1wQutvnE=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cargo
    meson
    ninja
    pkg-config
    rustPlatform.cargoSetupHook
    rustc
    wrapGAppsHook4
    blueprint-compiler
    desktop-file-utils
  ];

  buildInputs = [
    libadwaita
    webkitgtk_6_0
    glib-networking
  ]
  ++ (with gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-libav
  ]);

  preFixup = ''
    gappsWrapperArgs+=(
      --set FLATPAK_ID io.github.tobagin.karere
    )
  '';

  __structuredAttrs = true;

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-48ai2Jf/Uo+sXsT78v4usVEAn1zV/YVz4FZZs2ZZDa8=";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Gtk4 Whatsapp client";
    homepage = "https://github.com/tobagin/karere";
    changelog = "https://github.com/tobagin/karere/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      marcel
      aleksana
    ];

    mainProgram = "karere";
  };
})
