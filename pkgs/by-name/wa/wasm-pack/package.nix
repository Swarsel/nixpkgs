{
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  rustPlatform,
  zstd,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "wasm-pack";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "wasm-bindgen";
    repo = "wasm-pack";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+M59AC/dz8WwK9+854QZjSPuikTW+x6Nx2FKnr7qiXs=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [ zstd ];
  cargoHash = "sha256-u8LFx2D9LDa9W/ghRWZ9N/vOBr0bAkTdnZt9YaKrD30=";
  # Most tests rely on external resources and build artifacts.
  # Disabling check here to work with build sandboxing.
  doCheck = false;

  meta = {
    description = "Utility that builds rust-generated WebAssembly package";
    homepage = "https://github.com/wasm-bindgen/wasm-pack";
    changelog = "https://github.com/wasm-bindgen/wasm-pack/blob/v${finalAttrs.version}/CHANGELOG.md";

    license = with lib.licenses; [
      asl20 # or
      mit
    ];

    maintainers = with lib.maintainers; [
      dhkl
      hythera
    ];

    mainProgram = "wasm-pack";
  };
})
