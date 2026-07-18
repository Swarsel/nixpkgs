{
  lib,
  fetchFromGitHub,
  fontconfig,
  libxkbcommon,
  makeWrapper,
  pkg-config,
  rustPlatform,
  wayland,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "kickoff";
  version = "0.7.6";

  src = fetchFromGitHub {
    owner = "j0ru";
    repo = "kickoff";
    rev = "v${finalAttrs.version}";
    hash = "sha256-hDonn6as5TGoYOOFVzhWxOUKzqEQ66aFWz0O3gtBGS4=";
  };

  nativeBuildInputs = [
    makeWrapper
    pkg-config
  ];

  buildInputs = [
    fontconfig
    libxkbcommon
  ];

  cargoHash = "sha256-DOkgKcLPZzZaC+2vWNZ4BoaR0HhoaaKYQS7IQUJtK44=";

  postInstall = ''
    wrapProgram "$out/bin/kickoff" --prefix LD_LIBRARY_PATH : "${finalAttrs.libPath}"
  '';

  libPath = lib.makeLibraryPath [
    wayland
    libxkbcommon
  ];

  meta = {
    description = "Minimalistic program launcher";
    homepage = "https://github.com/j0ru/kickoff";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ pyxels ];
    platforms = lib.platforms.linux;
    mainProgram = "kickoff";
  };
})
