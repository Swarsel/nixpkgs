{
  lib,
  stdenv,
  fetchFromGitHub,
  libxkbcommon,
  meson,
  ninja,
  pkg-config,
  wayland,
  wayland-scanner,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wtype";
  version = "0.4";

  src = fetchFromGitHub {
    owner = "atx";
    repo = "wtype";
    rev = "v${finalAttrs.version}";
    hash = "sha256-TfpzAi0mkXugQn70MISyNFOXIJpDwvgh3enGv0Xq8S4=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wayland-scanner
  ];

  buildInputs = [
    libxkbcommon
    wayland
  ];

  meta = {
    description = "xdotool type for wayland";
    homepage = "https://github.com/atx/wtype";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ justinlovinger ];
    platforms = lib.platforms.linux;
    mainProgram = "wtype";
  };
})
