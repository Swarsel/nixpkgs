{
  lib,
  stdenv,
  fetchFromGitHub,
  bison,
  doxygen,
  libx11,
  libxcb,
  libxml2,
  meson,
  ninja,
  pkg-config,
  python3,
  setxkbmap,
  testers,
  wayland,
  wayland-protocols,
  wayland-scanner,
  xkbcomp,
  xkeyboard_config,
  # To enable the "interactive-wayland" subcommand of xkbcli. This is the
  # wayland equivalent of `xev` on X11.
  xvfb,
  withWaylandTools ? stdenv.hostPlatform.isLinux,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libxkbcommon";
  version = "1.13.2";

  src = fetchFromGitHub {
    owner = "xkbcommon";
    repo = "libxkbcommon";
    tag = "xkbcommon-${finalAttrs.version}";
    hash = "sha256-JdS4+HPHDUUOUq5TUX2F5DicHif8wD3cPvMocWhD4S4=";
  };

  outputs = [
    "out"
    "dev"
    "doc"
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    bison
    doxygen
  ]
  ++ lib.optional stdenv.hostPlatform.isLinux xvfb
  ++ lib.optional withWaylandTools wayland-scanner;

  buildInputs = [
    xkeyboard_config
    libxcb
    libxml2
  ]
  ++ lib.optionals withWaylandTools [
    wayland
    wayland-protocols
  ];

  mesonFlags = [
    "-Dxkb-config-root=${xkeyboard_config}/etc/X11/xkb"
    "-Dxkb-config-extra-path=/etc/xkb" # default=$sysconfdir/xkb ($out/etc)
    "-Dx-locale-root=${libx11.out}/share/X11/locale"
    "-Denable-docs=true"
    "-Denable-wayland=${lib.boolToString withWaylandTools}"
  ];

  doCheck = stdenv.hostPlatform.isLinux; # TODO: disable just a part of the tests

  nativeCheckInputs = [
    python3
    setxkbmap
    xkbcomp
  ];

  preCheck = ''
    patchShebangs ../test/
  '';

  depsBuildBuild = [ pkg-config ];

  passthru = {
    tests.pkg-config = testers.hasPkgConfigModules {
      package = finalAttrs.finalPackage;
    };
  };

  meta = {
    description = "Library to handle keyboard descriptions";

    longDescription = ''
      libxkbcommon is a keyboard keymap compiler and support library which
      processes a reduced subset of keymaps as defined by the XKB (X Keyboard
      Extension) specification. It also contains a module for handling Compose
      and dead keys.
    ''; # and a separate library for listing available keyboard layouts.

    homepage = "https://xkbcommon.org";
    changelog = "https://github.com/xkbcommon/libxkbcommon/blob/xkbcommon-${finalAttrs.version}/NEWS.md";
    license = lib.licenses.mit;

    maintainers = [
    ];

    platforms = with lib.platforms; unix;
    mainProgram = "xkbcli";

    pkgConfigModules = [
      "xkbcommon"
      "xkbcommon-x11"
      "xkbregistry"
    ];
  };
})
