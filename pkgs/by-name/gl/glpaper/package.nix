{
  lib,
  stdenv,
  fetchFromSourcehut,
  libGL,
  libx11,
  meson,
  ninja,
  pkg-config,
  wayland,
}:

stdenv.mkDerivation {
  pname = "glpaper";
  version = "unstable-2024-08-07";

  src = fetchFromSourcehut {
    owner = "~scoopta";
    repo = "glpaper";
    rev = "af9827d20bfe1956dd88fb2202b38ed0de705305";
    sha256 = "sha256-zgvnWqsw243jZ9e6fG6L0hDfRRHwzmIdsxwnnWhimu0=";
    vc = "hg";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    wayland
    libx11 # required by libglvnd
    libGL
  ];

  # nop() is used as a typed Wayland callback stub, which GCC 15 rejects as an error.
  env.NIX_CFLAGS_COMPILE = "-Wno-error=incompatible-pointer-types";

  meta = {
    description = "Wallpaper program for wlroots based Wayland compositors such as sway that allows you to render glsl shaders as your wallpaper";
    homepage = "https://hg.sr.ht/~scoopta/glpaper";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ccellado ];
    platforms = lib.platforms.linux;
    mainProgram = "glpaper";
  };
}
