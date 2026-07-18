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
  pname = "xf86-video-sisusb";
  version = "0.9.7";

  src = fetchFromGitLab {
    owner = "driver";
    repo = "xf86-video-sisusb";
    tag = "xf86-video-sisusb-${finalAttrs.version}";
    hash = "sha256-Z4q1ChH+u5u+NOsrwTnBVF2iJbvkd/stffdCRK73DS8=";
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
    updateScript = nix-update-script { extraArgs = [ "--version-regex=xf86-video-sisusb-(.*)" ]; };
  };

  meta = {
    description = "SiS Net2280-based USB video driver for the Xorg X server";
    homepage = "https://gitlab.freedesktop.org/xorg/driver/xf86-video-sisusb";

    license = with lib.licenses; [
      bsd3
      hpndSellVariant
    ];

    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
