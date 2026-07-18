{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  libevdev,
  mtdev,
  nix-update-script,
  pkg-config,
  testers,
  udev,
  util-macros,
  xorg-server,
  xorgproto,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "xf86-input-evdev";
  version = "2.11.0";

  src = fetchFromGitLab {
    owner = "driver";
    repo = "xf86-input-evdev";
    tag = "xf86-input-evdev-${finalAttrs.version}";
    hash = "sha256-tXB50laCJcLoBbwM/hE+qEiHzmN7Q+r8uu6NPlRmpTM=";
    domain = "gitlab.freedesktop.org";
    group = "xorg";
  };

  # to get rid of xorg-server.dev; man is tiny
  outputs = [
    "out"
    "dev"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    util-macros
  ];

  buildInputs = [
    xorgproto
    libevdev
    udev
    mtdev
    xorg-server
  ];

  configureFlags = [
    "--with-sdkdir=${placeholder "dev"}/include/xorg"
  ];

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;
    updateScript = nix-update-script { extraArgs = [ "--version-regex=xf86-input-evdev-(.*)" ]; };
  };

  meta = {
    description = "Generic Linux input driver for the Xorg X server";
    homepage = "https://gitlab.freedesktop.org/xorg/driver/xf86-input-evdev";

    license = with lib.licenses; [
      hpndSellVariant
      mit
    ];

    maintainers = with lib.maintainers; [
      nick-linux
    ];

    platforms = lib.platforms.unix;
    pkgConfigModules = [ "xorg-evdev" ];
  };
})
