{
  lib,
  fetchFromGitHub,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ezno";
  version = "0.0.23";

  src = fetchFromGitHub {
    owner = "kaleidawave";
    repo = "ezno";
    rev = "release/ezno-${finalAttrs.version}";
    hash = "sha256-YS0DgRtCy+RJsPMDBvAxjF4vjxfCb5gmQWP7YPUWbWU=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  cargoHash = "sha256-7qTaI8nXH86yIXat584WI6AbJVRZ4PBXdnYDebUrpPA=";

  cargoBuildFlags = [
    "--bin"
    "ezno"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "JavaScript compiler and TypeScript checker with a focus on static analysis and runtime performance";
    homepage = "https://github.com/kaleidawave/ezno";
    changelog = "https://github.com/kaleidawave/ezno/releases/tag/release/ezno-${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.progrm_jarvis ];
    mainProgram = "ezno";
  };
})
