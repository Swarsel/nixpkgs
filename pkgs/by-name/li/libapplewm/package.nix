{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  libx11,
  libxext,
  pkg-config,
  testers,
  util-macros,
  xorgproto,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "libapplewm";
  version = "1.4.1-unstable-2021-01-04";

  src = fetchFromGitLab {
    owner = "xorg/lib";
    repo = "libapplewm";
    rev = "be972ebc3a97292e7d2b2350eff55ae12df99a42";
    hash = "sha256-NH9YeOEtnEupqpnsMLC21I+LmCOzT7KnfdzNNWqba/Y=";
    domain = "gitlab.freedesktop.org";
  };

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
    util-macros
  ];

  buildInputs = [
    xorgproto
    libx11
    libxext
  ];

  passthru = {
    # updateScript = # no updatescript since we don't use a tagged release (last one was 14 years ago)
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;
  };

  meta = {
    description = "Xlib-based library for the Apple-WM extension";

    longDescription = ''
      AppleWM is a simple library designed to interface with the Apple-WM extension.
      This extension allows X window managers to better interact with the Mac OS X Aqua user
      interface when running X11 in a rootless mode.
    '';

    homepage = "https://gitlab.freedesktop.org/xorg/lib/libapplewm";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.darwin;
    pkgConfigModules = [ "applewm" ];
  };
})
