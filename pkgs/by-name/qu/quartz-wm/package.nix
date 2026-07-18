{
  lib,
  autoreconfHook,
  clangStdenv,
  fetchgit,
  libapplewm,
  libxext,
  libxinerama,
  libxrandr,
  pixman,
  pkg-config,
  util-macros,
  xorgproto,
}:

clangStdenv.mkDerivation (finalAttrs: {
  pname = "quartz-wm";
  version = "1.3.2";

  src = fetchgit {
    url = "https://gitlab.freedesktop.org/xorg/app/quartz-wm.git";
    tag = "quartz-wm-${finalAttrs.version}";
    hash = "sha256-1+KZNeR4Gq2uWBHTN53PTITHuly1Z4buR+grzdVNwhs=";
  };

  patches = [ ./fix-picture-typedef-conflict.patch ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    util-macros
  ];

  buildInputs = [
    libxinerama
    libapplewm
    xorgproto
    libxrandr
    libxext
    pixman
  ];

  configureFlags = [ "--enable-xplugin-dock-support" ];

  meta = {
    homepage = "https://gitlab.freedesktop.org/xorg/app/quartz-wm";
    license = lib.licenses.apple-psl20;
    maintainers = [ lib.maintainers.booxter ];
    platforms = lib.platforms.darwin;
    mainProgram = "quartz-wm";
  };
})
