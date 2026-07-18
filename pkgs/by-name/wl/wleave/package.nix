{
  lib,
  fetchFromGitHub,
  at-spi2-atk,
  glib,
  gtk4,
  gtk4-layer-shell,
  # Deps
  installShellFiles,
  libadwaita,
  librsvg,
  libxml2,
  nix-update-script,
  pkg-config,
  rustPlatform,
  scdoc,
  wrapGAppsHook4,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "wleave";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "AMNatty";
    repo = "wleave";
    rev = finalAttrs.version;
    hash = "sha256-AiZVa8+nCrxgi6E54Aa6+At+6JUZkwESpe5v72S8HyA=";
  };

  postPatch = ''
    substituteInPlace src/config.rs \
      --replace-fail "/etc/wleave" "$out/etc/wleave"

    substituteInPlace layout.json \
      --replace-fail "/usr/share/wleave" "$out/share/wleave"
  '';

  nativeBuildInputs = [
    installShellFiles
    pkg-config
    scdoc
    wrapGAppsHook4
  ];

  buildInputs = [
    at-spi2-atk
    glib
    gtk4
    gtk4-layer-shell
    libadwaita
    librsvg
    libxml2
  ];

  cargoHash = "sha256-tBjL1l9YH0P6effTYES9urYdKtUh/H3hCI5hUphb9tQ=";

  postInstall = ''
    install -Dm644 -t "$out/etc/wleave" {"style.css","layout.json"}
    install -Dm644 -t "$out/share/wleave/icons" icons/*

    # Man pages are currently broken due to upstream scdoc syntax errors.
    # Disable generation until upstream fixes them.
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Wayland-native logout script written in GTK4";
    homepage = "https://github.com/AMNatty/wleave";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ludovicopiero ];
    platforms = lib.platforms.linux;
    mainProgram = "wleave";
  };
})
