{
  lib,
  fetchFromGitHub,
  bzip2,
  nix-update-script,
  pkg-config,
  rustPlatform,
  zstd,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rust-traverse";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "dmcg310";
    repo = "Rust-Traverse";
    tag = "v${finalAttrs.version}";
    hash = "sha256-OcCWmBNDo4AA5Pk5TQqb8hen9LlHaY09Wrm4BkrU7qA=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    bzip2
    zstd
  ];

  cargoHash = "sha256-UGPXV55+0w6QFYxfmmimSX/dleCdtEahveNi8DgSVzQ=";

  env = {
    ZSTD_SYS_USE_PKG_CONFIG = true;
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Terminal based file explorer";
    homepage = "https://github.com/dmcg310/Rust-Traverse";
    changelog = "https://github.com/dmcg310/Rust-Traverse/releases/tag/${finalAttrs.src.rev}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.progrm_jarvis ];
    mainProgram = "rt";
  };
})
