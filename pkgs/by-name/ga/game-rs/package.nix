{
  lib,
  fetchFromGitHub,
  rustPlatform,
  umu-launcher,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "game-rs";
  version = "5";

  src = fetchFromGitHub {
    owner = "amanse";
    repo = "game-rs";
    rev = "z${finalAttrs.version}";
    hash = "sha256-+LQxU4jWBAOk+qHNvGxYXudX5dG6szQt3PiPI41Zxlo=";
  };

  propagatedBuildInputs = [ umu-launcher ];
  cargoHash = "sha256-X9dWIeDKy3qLmFwUevN8ZUcwNVtt7Wnecbg7M6zUXFU=";

  meta = {
    description = "Minimal CLI game launcher for linux";
    homepage = "https://github.com/amanse/game-rs";
    changelog = "https://github.com/Amanse/game-rs/releases/tag/v${finalAttrs.version}";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ amanse ];
    platforms = lib.platforms.linux;
  };
})
