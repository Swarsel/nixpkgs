{
  lib,
  fetchFromGitHub,
  pkg-config,
  rustPlatform,
  zstd,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cargo-deny";
  version = "0.20.2";

  src = fetchFromGitHub {
    owner = "EmbarkStudios";
    repo = "cargo-deny";
    tag = finalAttrs.version;
    hash = "sha256-sYxRQvJVbVmzajGJdAHnuvJDELv0cyDCCU8cRU0U0oQ=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    zstd
  ];

  cargoHash = "sha256-Zb6vQCnhhhL9Ducn9eh5P8Gfopl0lQPTXWW8Q0Y5xBQ=";

  env = {
    ZSTD_SYS_USE_PKG_CONFIG = true;
  };

  # tests require internet access
  doCheck = false;

  meta = {
    description = "Cargo plugin for linting your dependencies";
    homepage = "https://github.com/EmbarkStudios/cargo-deny";
    changelog = "https://github.com/EmbarkStudios/cargo-deny/blob/${finalAttrs.version}/CHANGELOG.md";

    license = with lib.licenses; [
      asl20 # or
      mit
    ];

    maintainers = with lib.maintainers; [
      matthiasbeyer
      jk
      chrjabs
    ];

    mainProgram = "cargo-deny";
  };
})
