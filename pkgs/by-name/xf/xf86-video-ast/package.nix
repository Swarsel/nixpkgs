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
  pname = "xf86-video-ast";
  version = "1.2.1";

  src = fetchFromGitLab {
    owner = "driver";
    repo = "xf86-video-ast";
    tag = "xf86-video-ast-${finalAttrs.version}";
    hash = "sha256-Xz9ZvngAsEb/9+YOGOkJQIbFzofKw+2V6sST8Ry2tvo=";
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
    updateScript = nix-update-script { extraArgs = [ "--version-regex=xf86-video-ast-(.*)" ]; };
  };

  meta = {
    description = "ASpeed Technologies graphics driver for the Xorg X server";
    homepage = "https://gitlab.freedesktop.org/xorg/driver/xf86-video-ast";
    license = lib.licenses.hpndSellVariant;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    broken = stdenv.hostPlatform.isAarch64;
  };
})
