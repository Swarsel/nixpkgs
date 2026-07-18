{
  lib,
  stdenv,
  bzip2,
  fetchFromGitea,
  liburing,
  matrix-continuwuity,
  nix-update-script,
  nixosTests,
  pkg-config,
  rocksdb,
  rust-jemalloc-sys-unprefixed,
  rustPlatform,
  testers,
  zstd,
}:
let
  rocksdb' =
    (rocksdb.override {
      # rocksdb does not support prefixed jemalloc, which is required on darwin
      enableJemalloc = !stdenv.hostPlatform.isDarwin;
      jemalloc = rust-jemalloc-sys-unprefixed;
    }).overrideAttrs
      (
        final: old: {
          version = "11.1.1";

          src = fetchFromGitea {
            owner = "continuwuation";
            repo = "rocksdb";
            rev = "3756b2b905e13216d8b56bcc783d814e7b073aff";
            hash = "sha256-rSv4fr2bf9JJwdodgeuPCuceeh7k97KVxrAOC0wyPQY=";
            domain = "forgejo.ellis.link";
          };

          patches = [ ];
        }
      );
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "matrix-continuwuity";
  version = "26.6.2";

  src = fetchFromGitea {
    owner = "continuwuation";
    repo = "continuwuity";
    tag = "v${finalAttrs.version}";
    hash = "sha256-GcCjJiUOGX+vF7R4IRgNQs8KpfVj+MXwnhofwSm6gpA=";
    domain = "forgejo.ellis.link";
  };

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    bzip2
    zstd
    rust-jemalloc-sys-unprefixed
    liburing
  ];

  cargoHash = "sha256-p1Bz7op/qPogBn8bj9pQ7KjRhH2kZao8o0LPqWH2ZYo=";

  env = {
    ROCKSDB_INCLUDE_DIR = "${rocksdb'}/include";
    ROCKSDB_LIB_DIR = "${rocksdb'}/lib";
    ZSTD_SYS_USE_PKG_CONFIG = true;
  };

  passthru = {
    rocksdb = rocksdb'; # make used rocksdb version available (e.g., for backup scripts)

    tests = {
      version = testers.testVersion {
        inherit (finalAttrs) version;
        package = matrix-continuwuity;
      };
    }
    // lib.optionalAttrs stdenv.hostPlatform.isLinux {
      inherit (nixosTests) matrix-continuwuity;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Matrix homeserver written in Rust, forked from conduwuit";
    homepage = "https://continuwuity.org/";
    changelog = "https://forgejo.ellis.link/continuwuation/continuwuity/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      bartoostveen
      nyabinary
      snaki
    ];

    # Not a typo, continuwuity is a drop-in replacement for conduwuit.
    mainProgram = "conduwuit";
  };
})
