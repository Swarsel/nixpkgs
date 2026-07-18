{
  lib,
  stdenv,
  fetchFromGitHub,
  gtk-layer-shell,
  gtk3,
  installShellFiles,
  libdbusmenu-gtk3,
  librsvg,
  nix-update-script,
  pkg-config,
  rustPlatform,
  wrapGAppsHook3,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "eww";
  version = "0.6.0-unstable-2026-07-05";

  src = fetchFromGitHub {
    owner = "elkowar";
    repo = "eww";
    rev = "4ded06345553e4c2bcf8179fc7438e53c5e54d89";
    hash = "sha256-fnI8XgBowMxs/j9FGf+pQI2U8YjN8pTRqkVmFm8PBHE=";
  };

  nativeBuildInputs = [
    installShellFiles
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    gtk-layer-shell
    libdbusmenu-gtk3
    librsvg
  ];

  cargoHash = "sha256-Kf99eojqXvdbZ3eRS8GBgyLYNpZKJGIJtsOsvhhSVDk=";
  # requires unstable rust features
  env.RUSTC_BOOTSTRAP = 1;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd eww \
      --bash <($out/bin/eww shell-completions --shell bash) \
      --fish <($out/bin/eww shell-completions --shell fish) \
      --zsh <($out/bin/eww shell-completions --shell zsh)
  '';

  cargoBuildFlags = [
    "--bin"
    "eww"
  ];

  cargoTestFlags = finalAttrs.cargoBuildFlags;
  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Widget system made in Rust to create widgets for any WM";

    longDescription = ''
      Eww (ElKowar's Wacky Widgets) is a widget system made in Rust which lets
      you create your own widgets similarly to how you can in AwesomeWM.
      The key difference: It is independent of your window manager!
      It can be configured in yuck and themed using CSS, is very easy
      to customize and provides all the flexibility you need!
    '';

    homepage = "https://github.com/elkowar/eww";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      w-lfchen
    ];

    mainProgram = "eww";
    broken = stdenv.hostPlatform.isDarwin;
  };
})
