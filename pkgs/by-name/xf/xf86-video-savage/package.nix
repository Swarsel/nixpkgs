{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  libdrm,
  libpciaccess,
  nix-update-script,
  pkg-config,
  util-macros,
  xorg-server,
  xorgproto,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "xf86-video-savage";
  version = "2.4.1";

  src = fetchFromGitLab {
    owner = "driver";
    repo = "xf86-video-savage";
    tag = "xf86-video-savage-${finalAttrs.version}";
    hash = "sha256-MimTtOPSVQ0uEREYNJDqwDOF2RaNxv/pWmhxcqVfSqA=";
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
    libdrm
    libpciaccess
  ];

  passthru = {
    updateScript = nix-update-script { extraArgs = [ "--version-regex=xf86-video-savage-(.*)" ]; };
  };

  meta = {
    description = "S3 Savage video driver for the Xorg X server";
    homepage = "https://gitlab.freedesktop.org/xorg/driver/xf86-video-savage";

    license = with lib.licenses; [
      x11
      mit
    ];

    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
