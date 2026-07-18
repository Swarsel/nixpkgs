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
  pname = "xf86-video-siliconmotion";
  version = "1.7.10";

  src = fetchFromGitLab {
    owner = "driver";
    repo = "xf86-video-siliconmotion";
    tag = "xf86-video-siliconmotion-${finalAttrs.version}";
    hash = "sha256-CRuzdxlES6TFMDGIKk5sBAXF2Pa781jmTzlVT+A2Muk=";
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

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version-regex=xf86-video-siliconmotion-(.*)" ];
  };

  meta = {
    description = "Silicon Motion video driver for the Xorg X server";
    homepage = "https://gitlab.freedesktop.org/xorg/driver/xf86-video-siliconmotion";

    license = with lib.licenses; [
      x11
      mit
    ];

    maintainers = [ ];
    platforms = lib.platforms.unix;
    broken = stdenv.hostPlatform.isAarch64;
  };
})
