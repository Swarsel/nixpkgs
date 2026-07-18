{
  lib,
  fetchFromGitHub,
  git,
  gitls,
  openssl,
  pkg-config,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "licensure";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "chasinglogic";
    repo = "licensure";
    rev = finalAttrs.version;
    hash = "sha256-3kZzYDKMLRdYzxa9+wVeTFJk186MJZfGfzRXgY9tI4Y=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    openssl
    git
    gitls
  ];

  cargoHash = "sha256-b3Vb8beULbLQuBORcE5nWuHkqDmalexJick9Ct5+iUM=";

  checkFlags = [
    # Checking for files in the git repo (git ls-files),
    # That obviously does not work with nix
    "--skip=test_get_project_files"
  ];

  meta = {
    description = "FOSS License management tool for your projects";
    homepage = "https://github.com/chasinglogic/licensure";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.bpeetz ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "licensure";
  };
})
