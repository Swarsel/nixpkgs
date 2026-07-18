{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  libx11,
  libxcb,
  qt6,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "whatsie";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "keshavbhatt";
    repo = "whatsie";
    tag = "v${finalAttrs.version}";
    hash = "sha256-GVXwZZFfPqAmBrP95zleHc2PpMMBj/8xZdW4JpFdYVs=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    libx11
    libxcb
    qt6.qtwebengine
  ];

  enableParallelBuilding = true;

  meta = {
    description = "Feature rich WhatsApp Client for Desktop Linux";
    homepage = "https://github.com/keshavbhatt/whatsie";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ajgon ];
    platforms = lib.platforms.linux;
    mainProgram = "whatsie";
  };
})
