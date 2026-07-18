{
  lib,
  stdenv,
  fetchFromGitHub,
  libGL,
  libjpeg,
  libpng,
  libx11,
  libxrandr,
  meson,
  ninja,
  pkg-config,
  versionCheckHook,
  wayland,
  wayland-protocols,
  wayland-scanner,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "neowall";
  version = "0.5.2";

  src = fetchFromGitHub {
    owner = "1ay1";
    repo = "neowall";
    tag = "v${finalAttrs.version}";
    hash = "sha256-XK3A/B37R5mQWzdiMwwDkSHMC87sHXDvtOXvnaGCuJ0=";
  };

  nativeBuildInputs = [
    pkg-config
    wayland-scanner
    meson
    ninja
  ];

  buildInputs = [
    wayland
    wayland-protocols
    libx11
    libxrandr
    libGL
    libpng
    libjpeg
  ];

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  installFlags = [ "PREFIX=${placeholder "out"}" ];
  versionCheckProgramArg = "--version";

  meta = {
    description = "GPU shader wallpapers for Wayland";
    homepage = "https://github.com/1ay1/neowall";
    changelog = "https://github.com/1ay1/neowall/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ lonerOrz ];
    platforms = lib.platforms.linux;
    mainProgram = "neowall";
  };
})
