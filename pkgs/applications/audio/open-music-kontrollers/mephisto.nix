{
  lib,
  stdenv,
  cmake,
  faust,
  fetchFromSourcehut,
  fontconfig,
  glew,
  libvterm-neovim,
  libx11,
  libxext,
  lv2,
  lv2lint,
  meson,
  ninja,
  pkg-config,
  sord,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mephisto";
  version = "0.18.2";

  src = fetchFromSourcehut {
    owner = "~hp";
    repo = "mephisto.lv2";
    rev = finalAttrs.version;
    hash = "sha256-ab6OGt1XVgynKNdszzdXwJ/jVKJSzgSmAv6j1U3/va0=";
    domain = "open-music-kontrollers.ch";
  };

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    fontconfig
    cmake
  ];

  buildInputs = [
    faust
    libvterm-neovim
    lv2
    sord
    libx11
    libxext
    glew
    lv2lint
  ];

  meta = {
    description = "Just-in-time FAUST embedded in an LV2 plugin";
    homepage = "https://git.open-music-kontrollers.ch/~hp/mephisto.lv2";
    license = lib.licenses.artistic2;
    maintainers = [ lib.maintainers.magnetophon ];
    platforms = lib.platforms.linux;
  };
})
