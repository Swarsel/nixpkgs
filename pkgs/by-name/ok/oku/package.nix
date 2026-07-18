{
  lib,
  fetchFromGitHub,
  fuse3,
  glib,
  gtk4,
  hicolor-icon-theme,
  libadwaita,
  nix-update-script,
  nixosTests,
  oniguruma,
  pango,
  pkg-config,
  rustPlatform,
  webkitgtk_6_0,
  wrapGAppsHook4,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "oku";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "okubrowser";
    repo = "oku";
    tag = "v${finalAttrs.version}";
    hash = "sha256-utbey8DFXUWU6u2H2unNjCHE3/bwhPdrxAOApC+unGA=";
  };

  nativeBuildInputs = [
    wrapGAppsHook4
    pkg-config
  ];

  buildInputs = [
    fuse3
    glib
    gtk4
    hicolor-icon-theme
    libadwaita
    oniguruma
    pango
    webkitgtk_6_0
  ];

  cargoHash = "sha256-rwf9jdr+RDpUcTEG7Xhpph0zuyz6tdFx6hWEZRuxkTY=";
  # use system oniguruma since the bundled one fails to build with gcc15
  env.RUSTONIG_SYSTEM_LIBONIG = 1;

  # the program expects icons to be installed but the
  # program does not install them itself
  postInstall = ''
    mkdir -p $out/share/icons
    cp -r ${finalAttrs.src}/data/hicolor $out/share/icons
  '';

  # Avoiding optimizations for reproducibility
  prePatch = ''
    substituteInPlace .cargo/config.toml \
      --replace-fail '"-C", "target-cpu=native", ' ""
  '';

  passthru = {
    tests = { inherit (nixosTests) oku; };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Browser for the Oku Network and Peer-to-peer sites";
    homepage = "https://github.com/okubrowser/oku";
    changelog = "https://github.com/OkuBrowser/oku/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ ethancedwards8 ];
    platforms = lib.platforms.linux;
    mainProgram = "oku";
    teams = with lib.teams; [ ngi ];
  };
})
