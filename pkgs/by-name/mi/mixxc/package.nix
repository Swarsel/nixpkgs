{
  lib,
  fetchCrate,
  gtk4,
  gtk4-layer-shell,
  installShellFiles,
  libpulseaudio,
  libxcb,
  pkg-config,
  rustPlatform,
  wrapGAppsHook4,
  enableSass ? true,
  enableWayland ? true,
  enableX11 ? true,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "mixxc";
  version = "0.2.5";

  src = fetchCrate {
    inherit (finalAttrs) version;
    hash = "sha256-YVh6SOXCf4GHqDduXP7QupC48hcIMQtjIdGJYXNXQ1E=";
    pname = "mixxc";
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [
    pkg-config
    installShellFiles
    wrapGAppsHook4
  ];

  buildInputs = [
    libpulseaudio
    gtk4
    (lib.optionals enableWayland gtk4-layer-shell)
    (lib.optionals enableX11 libxcb)
  ];

  cargoHash = "sha256-w+bHaGt6aq21DpmxYNQIf/YNigfrkqnAI25Q3l/WhHc=";

  postInstall = ''
    installManPage $src/doc/mixxc.1
  '';

  buildFeatures = [
    (lib.optionals enableWayland "Wayland")
    (lib.optionals enableX11 "X11")
    (lib.optionals enableSass "Sass")
  ];

  cargoBuildFlags = [ "--locked" ];

  meta = {
    description = "Minimalistic and customizable volume mixer";
    homepage = "https://github.com/Elvyria/mixxc";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ daru-san ];
    platforms = lib.platforms.linux;
    mainProgram = "mixxc";
  };
})
