{
  lib,
  fetchFromGitHub,
  bzip2,
  openssl,
  pkg-config,
  rustPlatform,
  zstd,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rtz";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "twitchax";
    repo = "rtz";
    rev = "v${finalAttrs.version}";
    hash = "sha256-V7N9NFIc/WWxLaahkjdS47Qj8sc3HRdKSkrBqi1ngA8=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    bzip2
    openssl
    zstd
  ];

  cargoHash = "sha256-Lm81Qnu3ZQw43fCcQOR63EV1aYXuPyR9Gy+F6BCiwUw=";
  buildFeatures = [ "web" ];

  meta = {
    description = "Tool to easily work with timezone lookups via a binary, a library, or a server";
    homepage = "https://github.com/twitchax/rtz";
    changelog = "https://github.com/twitchax/rtz/releases/tag/${finalAttrs.src.rev}";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "rtz";
  };
})
