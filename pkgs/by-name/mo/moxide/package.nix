{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "moxide";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "dlurak";
    repo = "moxide";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BTg1z3pU9mGnexlXBdJ5ZqJeykpzGmhCbEKtvVxGEKo=";
  };

  cargoHash = "sha256-j4yV86Hr6QZTZ/0Dy9y+2egxGqf1Z930Zg6dsKs5bxg=";

  meta = {
    description = "Tmux session manager with a modular configuration";
    homepage = "https://github.com/dlurak/moxide";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ dlurak ];
    mainProgram = "moxide";
  };
})
