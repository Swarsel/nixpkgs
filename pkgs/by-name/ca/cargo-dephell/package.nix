{
  lib,
  stdenv,
  fetchFromGitHub,
  curl,
  libgit2,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cargo-dephell";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "mimoo";
    repo = "cargo-dephell";
    rev = "v${finalAttrs.version}";
    hash = "sha256-NOjkKttA+mwPCpl4uiRIYD58DlMomVFpwnM9KGfWd+w=";
  };

  nativeBuildInputs = [
    pkg-config
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    curl
  ];

  buildInputs = [
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    curl
    libgit2
  ];

  cargoHash = "sha256-+5ElAfYuUfosXzR3O2QIFGy4QJuPrWDMg5LacZKi3c8=";

  env = {
    LIBGIT2_NO_VENDOR = 1;
  };

  cargoPatches = [
    # update Cargo.lock to work with openssl 3
    ./openssl3-support.patch
  ];

  meta = {
    description = "Tool to analyze the third-party dependencies imported by a rust crate or rust workspace";
    homepage = "https://github.com/mimoo/cargo-dephell";

    license = with lib.licenses; [
      mit # or
      asl20
    ];

    maintainers = with lib.maintainers; [
      matthiasbeyer
    ];

    mainProgram = "cargo-dephell";
    broken = stdenv.hostPlatform.isLinux;
  };
})
