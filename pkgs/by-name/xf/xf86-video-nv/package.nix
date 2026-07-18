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
  pname = "xf86-video-nv";
  version = "2.1.23";

  src = fetchFromGitLab {
    owner = "driver";
    repo = "xf86-video-nv";
    tag = "xf86-video-nv-${finalAttrs.version}";
    hash = "sha256-8I7PnxOPXrUv0Ezj1H2qgUQdRDE99znSqUaieP6Pu8s=";
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
    updateScript = nix-update-script { extraArgs = [ "--version-regex=xf86-video-nv-(.*)" ]; };
  };

  meta = {
    description = "Minimal NVIDIA video driver for the Xorg X server";
    homepage = "https://gitlab.freedesktop.org/xorg/driver/xf86-video-nv";

    license = with lib.licenses; [
      mit
      hpndSellVariant
    ];

    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
