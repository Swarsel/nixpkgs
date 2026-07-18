{
  lib,
  stdenv,
  fetchFromGitHub,
  curl,
  gitMinimal,
  libiconv,
  openssl,
  perl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cargo-crev";
  version = "0.27.1";

  src = fetchFromGitHub {
    owner = "crev-dev";
    repo = "cargo-crev";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-ezMpxYrJJ2zqEwCaDu2DFMwd6d/nfPVO6z2Lm4elIYE=";
  };

  nativeBuildInputs = [
    perl
    pkg-config
  ];

  buildInputs = [
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    libiconv
    curl
  ];

  cargoHash = "sha256-CYvvwgDZ+yAr7kLGEVZLVx7+sZUc5vu85AT5xLJBSbQ=";
  nativeCheckInputs = [ gitMinimal ];

  preCheck = ''
    export HOME=$(mktemp -d)
    git config --global user.name "Nixpkgs Test"
    git config --global user.email "nobody@example.com"
  '';

  meta = {
    description = "Cryptographically verifiable code review system for the cargo (Rust) package manager";
    homepage = "https://github.com/crev-dev/cargo-crev";

    license = with lib.licenses; [
      asl20
      mit
      mpl20
    ];

    maintainers = with lib.maintainers; [
      b4dm4n
      matthiasbeyer
    ];

    mainProgram = "cargo-crev";
  };
})
