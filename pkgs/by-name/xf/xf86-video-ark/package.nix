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
  pname = "xf86-video-ark";
  version = "0.7.6";

  src = fetchFromGitLab {
    owner = "driver";
    repo = "xf86-video-ark";
    tag = "xf86-video-ark-${finalAttrs.version}";
    hash = "sha256-IE35hEZVsfxjwrNxV/xtw8bdox9pwlO/Ra8vkcK19pM=";
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
    updateScript = nix-update-script { extraArgs = [ "--version-regex=xf86-video-ark-(.*)" ]; };
  };

  meta = {
    description = "ARK Logic video driver for the Xorg X server";
    homepage = "https://gitlab.freedesktop.org/xorg/driver/xf86-video-ark";
    license = lib.licenses.hpndSellVariant;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    badPlatforms = lib.platforms.aarch64;
  };
})
