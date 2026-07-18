{
  lib,
  fetchFromGitHub,
  cmake,
  fetchpatch,
  nix-update-script,
  openssl,
  pkg-config,
  protobuf,
  rustPlatform,
  sqlite,
  versionCheckHook,
  zstd,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "sqld";
  version = "0.24.33";

  src = fetchFromGitHub {
    owner = "tursodatabase";
    repo = "libsql";
    tag = "libsql-server-v${finalAttrs.version}";
    hash = "sha256-ufpYZdw/96QIQ43ex4FTA/aulouZPDkbmSt7X4YnEzo=";
  };

  patches = [ ];

  nativeBuildInputs = [
    cmake
    pkg-config
    protobuf
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    openssl
    sqlite
    zstd
  ];

  cargoHash = "sha256-n2STJfX1sEeSbr3v9xst3S7UgLrUIdqfokqlHLWCVzY=";

  env = {
    # error[E0425]: cannot find function `consume_budget` in module `tokio::task`
    RUSTFLAGS = "--cfg tokio_unstable";
    ZSTD_SYS_USE_PKG_CONFIG = true;
  };

  # requires a complex setup with podman for the end-to-end tests
  doCheck = false;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  cargoBuildFlags = [
    "--bin"
    "sqld"
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "LibSQL with extended capabilities like HTTP protocol, replication, and more";
    homepage = "https://github.com/tursodatabase/libsql";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "sqld";
  };
})
