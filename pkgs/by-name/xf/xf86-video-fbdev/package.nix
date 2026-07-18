{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  libpciaccess,
  nix-update-script,
  pkg-config,
  util-macros,
  xorg-server,
  xorgproto,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "xf86-video-fbdev";
  version = "0.5.1";

  src = fetchFromGitLab {
    owner = "driver";
    repo = "xf86-video-fbdev";
    tag = "xf86-video-fbdev-${finalAttrs.version}";
    hash = "sha256-JlSTosvQCiNeWbveYdj4+Ulgd/guc37xYUMaAhyS7K8=";
    domain = "gitlab.freedesktop.org";
    group = "xorg";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    util-macros
    xorg-server # for some autoconf macros
  ];

  buildInputs = [
    xorg-server
    xorgproto
    libpciaccess
  ];

  passthru = {
    updateScript = nix-update-script { extraArgs = [ "--version-regex=xf86-video-fbdev-(.*)" ]; };
  };

  meta = {
    description = "Framebuffer device video driver for the Xorg X server";
    homepage = "https://gitlab.freedesktop.org/xorg/driver/xf86-video-fbdev";
    license = lib.licenses.x11;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
