{
  lib,
  stdenv,
  fetchFromGitHub,
  curl,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cargo-cyclonedx";
  version = "0.5.9";

  src = fetchFromGitHub {
    owner = "CycloneDX";
    repo = "cyclonedx-rust-cargo";
    rev = "cargo-cyclonedx-${finalAttrs.version}";
    hash = "sha256-0d6e66Cvfm3YYw9Abb0Rs30qAKoNhGi8/hYLKAiPlyE=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    curl
  ];

  cargoHash = "sha256-ZXFKe6PToXVi5o9vNaPpUjUmBiqfdvA+Bp8MKnhJTlU=";
  # Test suite is broken since rustc 1.90, see:
  # https://github.com/CycloneDX/cyclonedx-rust-cargo/issues/807
  doCheck = false;

  meta = {
    description = "Creates CycloneDX Software Bill of Materials (SBOM) from Rust (Cargo) projects";

    longDescription = ''
      The CycloneDX module for Rust (Cargo) creates a valid CycloneDX Software
      Bill-of-Material (SBOM) containing an aggregate of all project
      dependencies. CycloneDX is a lightweight SBOM specification that is
      easily created, human and machine readable, and simple to parse.
    '';

    homepage = "https://github.com/CycloneDX/cyclonedx-rust-cargo";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ nikstur ];
    mainProgram = "cargo-cyclonedx";
  };
})
