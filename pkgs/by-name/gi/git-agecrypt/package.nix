{
  lib,
  fetchFromGitHub,
  git,
  libgit2,
  pkg-config,
  rustPlatform,
  zlib,
}:

rustPlatform.buildRustPackage {
  pname = "git-agecrypt";
  version = "0-unstable-2024-03-11";

  src = fetchFromGitHub {
    owner = "vlaci";
    repo = "git-agecrypt";
    rev = "126be86c515466c5878a60561f754a9ab4af6ee8";
    hash = "sha256-cmnBW/691mmLHq8tWpD3+zwCf7Wph5fcVdSxQGxqd1k=";
  };

  nativeBuildInputs = [
    pkg-config
    git
  ];

  buildInputs = [
    libgit2
    zlib
  ];

  cargoHash = "sha256-71puTOjuV3egkip8pbiYbKxfhoZYtnirp4NrgiXR13I=";

  meta = {
    description = "Alternative to git-crypt using age instead of GPG";
    homepage = "https://github.com/vlaci/git-agecrypt";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ kuznetsss ];
    mainProgram = "git-agecrypt";
  };
}
