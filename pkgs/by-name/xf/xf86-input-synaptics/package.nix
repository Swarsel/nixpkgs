{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  libevdev,
  libx11,
  libxi,
  libxtst,
  nix-update-script,
  pkg-config,
  testers,
  util-macros,
  xorg-server,
  xorgproto,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "xf86-input-synaptics";
  version = "1.10.0";

  src = fetchFromGitLab {
    owner = "driver";
    repo = "xf86-input-synaptics";
    tag = "xf86-input-synaptics-${finalAttrs.version}";
    hash = "sha256-IHkUxphSV6JOlTzIgXGl5hWb6OphJ9Lyzp/YS2phVQs=";
    domain = "gitlab.freedesktop.org";
    group = "xorg";
  };

  outputs = [
    "out"
    "dev"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    util-macros
    xorg-server
  ];

  buildInputs = [
    xorg-server
    xorgproto
    libevdev
    libx11
    libxi
    libxtst
  ];

  configureFlags = [
    "--with-sdkdir=${placeholder "dev"}/include/xorg"
    "--with-xorg-conf-dir=${placeholder "out"}/share/X11/xorg.conf.d"
  ];

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;
    updateScript = nix-update-script { extraArgs = [ "--version-regex=xf86-input-synaptics-(.*)" ]; };
  };

  meta = {
    description = "Synaptics touchpad driver for the Xorg X server";
    homepage = "https://gitlab.freedesktop.org/xorg/driver/xf86-input-synaptics";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    pkgConfigModules = [ "xorg-synaptics" ];
  };
})
