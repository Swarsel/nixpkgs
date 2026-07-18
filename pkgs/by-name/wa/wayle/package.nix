{
  lib,
  stdenv,
  fetchFromGitHub,
  copyDesktopItems,
  fftw,
  glib,
  gtk4-layer-shell,
  gtksourceview5,
  installShellFiles,
  libpulseaudio,
  libxkbcommon,
  makeDesktopItem,
  nix-update-script,
  pipewire,
  pixman,
  pkg-config,
  rustPlatform,
  udev,
  wrapGAppsHook4,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "wayle";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "wayle-rs";
    repo = "wayle";
    tag = "v${finalAttrs.version}";
    hash = "sha256-AOHehdowgxEV1b+CwrAhJsUqxQnARIGZPWMRcdH0h+U=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    copyDesktopItems
    glib
    installShellFiles
    pkg-config
    rustPlatform.bindgenHook
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk4-layer-shell.dev
    gtksourceview5
    # Not sure why ".dev" is needed here, but CMake doesn't find libxkbcommon otherwise
    libxkbcommon.dev
    pixman
    udev

    # for generating libcava bindings
    fftw.dev
    libpulseaudio
    pipewire.dev
  ];

  cargoHash = "sha256-4PUXJwUP5h/ggZQbY78BdqMh5oZes1XCeWuT2/S94Z4=";

  checkFlags = [
    # GTK4 failed to initialize (requires GUI?)
    "--skip=tests::css_loads_into_gtk4"
  ];

  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  preInstall = ''
    mkdir -p "$out/share/icons/hicolor/scalable/apps"
    cp -r resources/icons "$out/share"
    cp resources/wayle-settings.svg "$out/share/icons/hicolor/scalable/apps"
  '';

  postInstall =
    lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform)
      # bash
      ''
        installShellCompletion --cmd wayle \
          --bash <($out/bin/wayle completions bash) \
          --fish <($out/bin/wayle completions fish) \
          --zsh <($out/bin/wayle completions zsh)
      '';

  preFixup = ''
    # so wayle could access wayle-settings binary
    gappsWrapperArgs+=( --suffix PATH : $out/bin )
  '';

  __structuredAttrs = true;

  cargoBuildFlags = [
    "--bin=wayle"
    "--bin=wayle-settings"
  ];

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Settings"
        "DesktopSettings"
        "GTK"
      ];

      comment = "Configure the Wayle desktop shell";
      desktopName = "Wayle Settings";
      exec = "wayle-settings";
      genericName = "Shell Settings";
      icon = "wayle-settings";

      keywords = [
        "wayle"
        "settings"
        "shell"
        "bar"
        "wayland"
        "config"
      ];

      name = "com.wayle.settings.desktop";
      startupNotify = true;
      startupWMClass = "com.wayle.settings";
      terminal = false;
      type = "Application";
    })
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Wayland Elements - A compositor agnostic shell with extensive customization";
    homepage = "https://github.com/wayle-rs/wayle/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ PerchunPak ];
    platforms = lib.platforms.linux;
    mainProgram = "wayle";
  };
})
