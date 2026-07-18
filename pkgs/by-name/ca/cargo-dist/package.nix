{
  lib,
  fetchFromGitHub,
  bzip2,
  cacert,
  git,
  nix-update-script,
  pkg-config,
  rustPlatform,
  rustup,
  xz,
  zstd,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cargo-dist";
  version = "0.32.0";

  src = fetchFromGitHub {
    owner = "axodotdev";
    repo = "cargo-dist";
    tag = "v${finalAttrs.version}";
    hash = "sha256-WNbo3sm5tSNYQMLB4bjiNtLwp5pD4KAoyG2lwWYEpzk=";
  };

  # remove tests that require internet access
  postPatch = ''
    rm cargo-dist/tests/cli-tests.rs cargo-dist/tests/integration-tests.rs
  '';

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    bzip2
    xz
    zstd
  ];

  cargoHash = "sha256-gzaDAGAjWDcJyoES0foFOyhTP4HDsaQHrrwCQmAzXZA=";

  env = {
    SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";
    ZSTD_SYS_USE_PKG_CONFIG = true;
  };

  nativeCheckInputs = [
    git
    rustup
    cacert
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Tool for building final distributable artifacts and uploading them to an archive";
    homepage = "https://github.com/axodotdev/cargo-dist";
    changelog = "https://github.com/axodotdev/cargo-dist/blob/v${finalAttrs.version}/CHANGELOG.md";

    license = with lib.licenses; [
      asl20
      mit
    ];

    maintainers = with lib.maintainers; [
      matthiasbeyer
      mistydemeo
    ];

    mainProgram = "dist";
  };
})
