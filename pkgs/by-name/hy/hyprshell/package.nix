{
  lib,
  fetchFromGitHub,
  gcc,
  gtk4-layer-shell,
  hyprland,
  libadwaita,
  pixman,
  pkg-config,
  rustPlatform,
  wrapGAppsHook4,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "hyprshell";
  version = "4.10.8";

  src = fetchFromGitHub {
    owner = "H3rmt";
    repo = "hyprshell";
    tag = "v${finalAttrs.version}";
    hash = "sha256-GXegc0W2xiRuSCjMpVc5mmKP5YFCYn87M/POTalISCA=";
  };

  nativeBuildInputs = [
    wrapGAppsHook4
    pkg-config
  ];

  buildInputs = [
    libadwaita
    gtk4-layer-shell
  ];

  cargoHash = "sha256-idvY6AOLyx22Gy01kQyA4V8j0VupP5JNswsY4K5Oq9M=";

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : '${lib.makeBinPath [ gcc ]}'
      --prefix CPATH : '${
        lib.makeIncludePath (
          hyprland.buildInputs
          ++ [
            hyprland
            pixman
          ]
        )
      }'
    )
  '';

  meta = {
    description = "Modern GTK4-based window switcher and application launcher for Hyprland";
    homepage = "https://github.com/H3rmt/hyprshell";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ arminius-smh ];
    platforms = hyprland.meta.platforms;
    mainProgram = "hyprshell";
  };
})
