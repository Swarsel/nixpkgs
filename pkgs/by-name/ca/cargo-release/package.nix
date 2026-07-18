{
  lib,
  stdenv,
  fetchFromGitHub,
  curl,
  git,
  libgit2,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cargo-release";
  version = "1.1.3";

  src = fetchFromGitHub {
    owner = "crate-ci";
    repo = "cargo-release";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5fe+iIPZAKi8aQW2PfanO7U2d70Oc3KvL/RZTV9/ZU8=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libgit2
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    curl
  ];

  cargoHash = "sha256-abTQuKpVcjorr6RQ1t9sAzqvS39XT6lg4fALAqO68YI=";

  nativeCheckInputs = [
    git
  ];

  # disable vendored-libgit2 and vendored-openssl
  buildNoDefaultFeatures = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = ''Cargo subcommand "release": everything about releasing a rust crate'';
    homepage = "https://github.com/crate-ci/cargo-release";
    changelog = "https://github.com/crate-ci/cargo-release/blob/v${finalAttrs.version}/CHANGELOG.md";

    license = with lib.licenses; [
      asl20 # or
      mit
    ];

    maintainers = with lib.maintainers; [
      gerschtli
      progrm_jarvis
    ];

    mainProgram = "cargo-release";
  };
})
