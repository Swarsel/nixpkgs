{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  SDL2_image,
  SDL2_ttf,
  cmake,
  gitUpdater,
  inih,
  libx11,
  validatePkgConfig,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "flex-launcher";
  version = "2.2";

  src = fetchFromGitHub {
    owner = "complexlogic";
    repo = "flex-launcher";
    tag = "v${finalAttrs.version}";
    hash = "sha256-touQMOKvp+D1vIYvyz/nU7aU9g6VXpDN3BPgoK/iYfw=";
  };

  nativeBuildInputs = [
    cmake
    validatePkgConfig
  ];

  buildInputs = [
    SDL2
    SDL2_ttf
    SDL2_image
    libx11
    inih
  ];

  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  meta = {
    description = "Customizable HTPC application launcher";
    homepage = "https://complexlogic.github.io/flex-launcher/";
    changelog = "https://github.com/complexlogic/flex-launcher/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.unlicense;
    maintainers = with lib.maintainers; [ MasterEvarior ];
    platforms = lib.platforms.unix;
    mainProgram = "flex-launcher";
  };
})
