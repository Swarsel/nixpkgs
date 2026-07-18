{
  lib,
  fetchFromGitHub,
  pkg-config,
  rustPlatform,
  zstd,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cargo-about";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "EmbarkStudios";
    repo = "cargo-about";
    tag = finalAttrs.version;
    hash = "sha256-0iY/kZmPYoMAQVU+Z/GWom7IgllYwUM34A80dgFYnXs=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ zstd ];
  cargoHash = "sha256-Hp2PRwPpSUKdExOvF2szb8W5+juPv2HfK7cPBm1rm5Q=";

  env = {
    ZSTD_SYS_USE_PKG_CONFIG = true;
  };

  buildFeatures = [ "cli" ];

  meta = {
    description = "Cargo plugin to generate list of all licenses for a crate";
    homepage = "https://github.com/EmbarkStudios/cargo-about";
    changelog = "https://github.com/EmbarkStudios/cargo-about/blob/${finalAttrs.version}/CHANGELOG.md";

    license = with lib.licenses; [
      mit # or
      asl20
    ];

    maintainers = with lib.maintainers; [
      evanjs
      matthiasbeyer
    ];

    mainProgram = "cargo-about";
  };
})
