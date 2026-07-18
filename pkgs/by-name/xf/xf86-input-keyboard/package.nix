{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  nix-update-script,
  pkg-config,
  util-macros,
  xorg-server,
  xorgproto,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "xf86-input-keyboard";
  version = "2.1.0";

  src = fetchFromGitLab {
    owner = "driver";
    repo = "xf86-input-keyboard";
    tag = "xf86-input-keyboard-${finalAttrs.version}";
    hash = "sha256-M0D6oTAhnADI7pgWKt4ueHGbdMVDTVOXy3w07DGcCSg=";
    domain = "gitlab.freedesktop.org";
    group = "xorg";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    util-macros
  ];

  buildInputs = [
    xorgproto
    xorg-server
  ];

  passthru = {
    updateScript = nix-update-script { extraArgs = [ "--version-regex=xf86-input-keyboard-(.*)" ]; };
  };

  meta = {
    description = "Keyboard input driver for non-Linux platforms for the Xorg X server";
    homepage = "https://gitlab.freedesktop.org/xorg/driver/xf86-input-keyboard";

    license = [
      lib.licenses.x11
      lib.licenses.hpndSellVariant
    ]
    # only solaris part is MIT
    ++ lib.optional stdenv.hostPlatform.isSunOS lib.licenses.mit;

    maintainers = [ ];
    # platforms according to the readme:
    # BSD, GNU Hurd, illumos & Solaris
    platforms = with lib.platforms; freebsd ++ netbsd ++ openbsd ++ illumos;
  };
})
