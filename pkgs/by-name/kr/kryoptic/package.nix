{
  lib,
  stdenv,
  fetchFromGitHub,
  clang,
  glibc,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  sqlite,
  withPostQuantum ? true,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "kryoptic";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "latchset";
    repo = "kryoptic";
    tag = "v${finalAttrs.version}";
    hash = "sha256-WOihUHFNqjQGObd+pfiNnjBq5GL/9NDeBiC7VzF/ZwE=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    openssl
    sqlite
  ];

  cargoHash = "sha256-Kr2tvxPIcWS47ljH9l0qQTacX9BIV9vMmQyE8EG6qVE=";

  env = {
    # Pass these include paths for bindgen in via the environment.
    ${if !stdenv.hostPlatform.isDarwin then "OSSL_BINDGEN_CLANG_ARGS" else null} =
      "-I${lib.getInclude glibc}/include";

    LIBCLANG_PATH = "${lib.getLib clang.cc}/lib";
  };

  doCheck = true;

  cargoBuildFlags = [
    "--no-default-features"
    "--features=${
      lib.concatStringsSep "," (
        [
          "standard"
          "sqlitedb"
          "nssdb"
          "log"
        ]
        ++ lib.optionals withPostQuantum [
          "pqc" # post-quantum
        ]
        ++ lib.optionals (!stdenv.hostPlatform.isStatic) [
          "dynamic"
        ]
      )
    }"
  ];

  cargoPatches = [
    ./0001-Add-Cargo.lock.patch
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A PKCS#11 soft token written in Rust.";
    homepage = "https://github.com/latchset/kryoptic";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      numinit
    ];

    platforms = lib.platforms.all;
  };
})
