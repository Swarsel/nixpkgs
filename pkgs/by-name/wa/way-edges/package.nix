{
  lib,
  fetchFromGitHub,
  cairo,
  libpulseaudio,
  libxkbcommon,
  nix-update-script,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "way-edges";
  version = "0.12.1";

  src = fetchFromGitHub {
    owner = "way-edges";
    repo = "way-edges";
    tag = finalAttrs.version;
    hash = "sha256-hvIy5WAv+DqA8Agln2Wgc8dHG/yDktfUU1k/3nlwjmw=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    cairo
    libxkbcommon
    libpulseaudio
  ];

  cargoHash = "sha256-E1MmCUBZSXkV0oEJ7vHiO2YawnTteu24h2+IVgB71fc=";

  env.RUSTFLAGS = toString [
    "--cfg tokio_unstable"
    "--cfg tokio_uring"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Wayland client focusing on widgets hidden in your screen edge";
    homepage = "https://github.com/way-edges/way-edges";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ denperidge ];
    platforms = lib.platforms.linux;
    mainProgram = "way-edges";
  };
})
