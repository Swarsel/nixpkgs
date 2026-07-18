{
  lib,
  fetchFromCodeberg,
  nix-update-script,
  nixosTests,
  rust-jemalloc-sys,
  rustPlatform,
  stdenvNoCC,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "porxie";
  version = "0.3.3";

  src = fetchFromCodeberg {
    owner = "Blooym";
    repo = "porxie";
    rev = "v${finalAttrs.version}";
    hash = "sha256-nB0QbGJ6emO1WLbIYAvCni6Xjs1AgQo8in6Y3Tof01g=";
  };

  buildInputs = [ rust-jemalloc-sys ];
  cargoHash = "sha256-7iupGBdDvk4hofMVNuVTt67M7EOveYb3hD1mk2BJRbU=";

  checkFlags = [
    # Requires network access.
    "--skip=identity_service::tests::resolve_and_cache"
  ];

  __structuredAttrs = true;

  passthru = {
    tests = lib.optionalAttrs stdenvNoCC.hostPlatform.isLinux {
      porxie = nixosTests.porxie;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Porxie, an ATProto blob proxy for secure content delivery";
    homepage = "https://codeberg.org/Blooym/porxie";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ blooym ];
    platforms = lib.platforms.unix;
    mainProgram = "porxie";
  };
})
