{
  lib,
  stdenv,
  fetchFromSourcehut,
  meson,
  ninja,
  pkg-config,
  wayland,
  wayland-protocols,
  wayland-scanner,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "chayang";
  version = "0.1.0";

  src = fetchFromSourcehut {
    owner = "~emersion";
    repo = "chayang";
    rev = "v${finalAttrs.version}";
    hash = "sha256-3Vu9/Bu2WQe2Yx/2BK25pEpuPNwX6g3qoFUMznCFHeI=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wayland-scanner
  ];

  buildInputs = [
    wayland-protocols
    wayland
  ];

  depsBuildBuild = [
    pkg-config
  ];

  meta = {
    description = "Gradually dim the screen on Wayland";

    longDescription = ''
      Gradually dim the screen on Wayland.
      Can be used to implement a grace period before locking the session.
    '';

    homepage = "https://git.sr.ht/~emersion/chayang/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mxkrsv ];
    platforms = lib.platforms.linux;
    mainProgram = "chayang";
  };
})
