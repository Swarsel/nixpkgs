{
  lib,
  fetchFromGitHub,
  libgit2,
  openssl,
  pkg-config,
  rustPlatform,
  zlib,
}:

let
  version = "6.5.3";
in
rustPlatform.buildRustPackage {
  inherit version;
  pname = "git-mit";

  src = fetchFromGitHub {
    owner = "PurpleBooth";
    repo = "git-mit";
    tag = "v${version}";
    hash = "sha256-vk0TxbvjjFqyisyeet2s3mp7+aPb99Lp0iLU59+pNG0=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libgit2
    openssl
    zlib
  ];

  cargoHash = "sha256-54s4Jnc6C6ysQnQ4AyxxghbTVVkud4KrZ9wLZ83OZmQ=";

  env = {
    LIBGIT2_NO_VENDOR = 1;
  };

  meta = {
    description = "Minimalist set of hooks to aid pairing and link commits to issues";
    homepage = "https://github.com/PurpleBooth/git-mit";
    changelog = "https://github.com/PurpleBooth/git-mit/releases/tag/v${version}";
    license = lib.licenses.cc0;
    maintainers = [ lib.maintainers.matthiasbeyer ];
  };
}
