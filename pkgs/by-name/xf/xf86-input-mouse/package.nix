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
  pname = "xf86-input-mouse";
  version = "2.0.0";

  src = fetchFromGitLab {
    owner = "driver";
    repo = "xf86-input-mouse";
    tag = "xf86-input-mouse-${finalAttrs.version}";
    hash = "sha256-qPP0u7k1g30vw4A1c0fuVbQ9HHovTqWy8OAQ8uMGGg0=";
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
    util-macros
    xorgproto
    xorg-server
  ];

  configureFlags = [ "--with-sdkdir=${placeholder "out"}/include/xorg" ];

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;
    updateScript = nix-update-script { extraArgs = [ "--version-regex=xf86-input-mouse-(.*)" ]; };
  };

  meta = {
    description = "Mouse input driver for non-Linux platforms for the Xorg X server";

    longDescription = ''
      This driver is used on non-Linux operating systems such as BSD & Solaris, as modern Linux
      systems use the xf86-input-evdev or xf86-input-libinput drivers instead.
    '';

    homepage = "https://gitlab.freedesktop.org/xorg/driver/xf86-input-mouse";

    license = with lib.licenses; [
      mit
      hpndSellVariant
      x11
    ];

    maintainers = [ ];
    # platforms according to the readme
    platforms = with lib.platforms; freebsd ++ netbsd ++ openbsd ++ illumos;
    pkgConfigModules = [ "xorg-mouse" ];
  };
})
