{
  lib,
  fetchFromGitHub,
  curl,
  libgit2,
  openssl,
  pkg-config,
  rustPlatform,
  zlib,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cargo-codspeed";
  version = "5.0.1";

  src = fetchFromGitHub {
    owner = "CodSpeedHQ";
    repo = "codspeed-rust";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Zu5PltGimy+8JYTEh8fTflW/L4zTW94IKgldT5kzPjA=";
  };

  nativeBuildInputs = [
    curl
    pkg-config
  ];

  buildInputs = [
    curl
    libgit2
    openssl
    zlib
  ];

  cargoHash = "sha256-hihwHbyNAJcl/mUy9obh2UDZfUA9Lq64c1TRZbUr+L0=";

  env = {
    LIBGIT2_NO_VENDOR = 1;
  };

  checkFlags = [
    # requires an extra dependency, blit
    "--skip=test_package_in_deps_build"

    # requires criteron, which requires additional dependencies
    "--skip=test_cargo_config_rustflags"

    # requires additional dependencies
    "--skip=test_criterion_build_and_run_filtered_by_name"
    "--skip=test_criterion_build_and_run_filtered_by_name_single"
  ];

  cargoBuildFlags = [ "-p=cargo-codspeed" ];
  cargoTestFlags = finalAttrs.cargoBuildFlags;

  meta = {
    description = "Cargo extension to build & run your codspeed benchmarks";
    homepage = "https://github.com/CodSpeedHQ/codspeed-rust";
    changelog = "https://github.com/CodSpeedHQ/codspeed-rust/releases/tag/v${finalAttrs.version}";

    license = with lib.licenses; [
      mit
      asl20
    ];

    maintainers = with lib.maintainers; [ hythera ];
    mainProgram = "cargo-codspeed";
  };
})
