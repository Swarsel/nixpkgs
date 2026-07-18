{
  lib,
  fetchFromGitHub,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "sourcepawn-studio";
  version = "8.1.8";

  src = fetchFromGitHub {
    owner = "Sarrus1";
    repo = "sourcepawn-studio";
    tag = "v${finalAttrs.version}";
    hash = "sha256-piUgAvU5tbsYydEiF+70BAZVBK2t6SzG18MLf9cN+xM=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  cargoHash = "sha256-Cy8YPcmRWEyG6b4kouuj7KVmq2wBL8akw9v9sB30eF4=";

  checkFlags = [
    # requires rustup and rustfmt
    "--skip=tests::sourcegen::generate_node_kinds"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "LSP implementation for the SourcePawn programming language written in Rust";
    homepage = "https://sarrus1.github.io/sourcepawn-studio/";
    changelog = "https://github.com/Sarrus1/sourcepawn-studio/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.da157 ];
    mainProgram = "sourcepawn-studio";
  };
})
