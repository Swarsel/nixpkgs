{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  nix-update-script,
  pkg-config,
  testers,
  util-macros,
  xorg-server,
  xorgproto,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "xf86-input-joystick";
  version = "1.6.4";

  src = fetchFromGitLab {
    owner = "driver";
    repo = "xf86-input-joystick";
    tag = "xf86-input-joystick-${finalAttrs.version}";
    hash = "sha256-JxSnhWx5V3/pdlu3mwRNrgicdfaUK5nIwBK3reqchQs=";
    domain = "gitlab.freedesktop.org";
    group = "xorg";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    util-macros
    xorg-server # xorg-server defines autoconf macros that we need
  ];

  buildInputs = [
    util-macros # unused dependency but the build fails if pkg-config can't find it
    xorgproto
    xorg-server
  ];

  configureFlags = [ "--with-sdkdir=${placeholder "out"}/include/xorg" ];

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;
    updateScript = nix-update-script { extraArgs = [ "--version-regex=xf86-input-joystick-(.*)" ]; };
  };

  meta = {
    description = "Joystick input driver for the Xorg X server";
    homepage = "https://gitlab.freedesktop.org/xorg/driver/xf86-input-joystick";
    license = lib.licenses.hpndSellVariant;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    broken = stdenv.hostPlatform.isDarwin; # no darwin driver
    pkgConfigModules = [ "xorg-joystick" ];
  };
})
