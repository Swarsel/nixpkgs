{
  lib,
  stdenv,
  fetchFromGitHub,
  cairo,
  evdev-proto,
  gdk-pixbuf,
  json_c,
  libGL,
  libdrm,
  libevdev,
  libinput,
  librsvg,
  libxcb-wm,
  libxkbcommon,
  meson,
  ninja,
  nixosTests,
  pango,
  pcre2,
  pkg-config,
  replaceVars,
  scdoc,
  swaybg,
  systemd,
  wayland,
  wayland-protocols,
  wayland-scanner,
  wlroots_0_20,
  enableXWayland ? true,
  # Used by the NixOS module:
  isNixOS ? false,
  systemdSupport ? lib.meta.availableOn stdenv.hostPlatform systemd,
  trayEnabled ? systemdSupport,
}:

stdenv.mkDerivation (finalAttrs: {
  inherit
    enableXWayland
    isNixOS
    systemdSupport
    trayEnabled
    ;

  pname = "sway-unwrapped";
  version = "1.12";

  src = fetchFromGitHub {
    owner = "swaywm";
    repo = "sway";
    rev = finalAttrs.version;
    hash = "sha256-OcF7jOOHhFPhM5APn5riy8S5jsEr9jALCVh9nBtD7Nk=";
  };

  patches = [
    ./load-configuration-from-etc.patch

    (replaceVars ./fix-paths.patch {
      inherit swaybg;
    })
  ]
  ++ lib.optionals (!finalAttrs.isNixOS) [
    # References to /nix/store/... will get GC'ed which causes problems when
    # copying the default configuration:
    ./sway-config-no-nix-store-references.patch
  ]
  ++ lib.optionals finalAttrs.isNixOS [
    # Use /run/current-system/sw/share and /etc instead of /nix/store
    # references:
    ./sway-config-nixos-paths.patch
  ];

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wayland-scanner
    scdoc
  ];

  buildInputs = [
    libGL
    wayland
    libxkbcommon
    pcre2
    json_c
    libevdev
    pango
    cairo
    libinput
    gdk-pixbuf
    librsvg
    wayland-protocols
    libdrm
    (wlroots_0_20.override { inherit (finalAttrs) enableXWayland; })
  ]
  ++ lib.optionals stdenv.hostPlatform.isFreeBSD [
    evdev-proto
  ]
  ++ lib.optionals finalAttrs.enableXWayland [
    libxcb-wm
  ];

  mesonFlags =
    let
      inherit (lib.strings) mesonEnable mesonOption;

      # The "sd-bus-provider" meson option does not include a "none" option,
      # but it is silently ignored iff "-Dtray=disabled".  We use "basu"
      # (which is not in nixpkgs) instead of "none" to alert us if this
      # changes: https://github.com/swaywm/sway/issues/6843#issuecomment-1047288761
      # assert trayEnabled -> systemdSupport && dbusSupport;

      sd-bus-provider = if systemdSupport then "libsystemd" else "basu";
    in
    [
      (mesonOption "sd-bus-provider" sd-bus-provider)
      (mesonEnable "tray" finalAttrs.trayEnabled)
    ];

  depsBuildBuild = [
    pkg-config
  ];

  passthru.tests.basic = nixosTests.sway;

  meta = {
    description = "I3-compatible tiling Wayland compositor";

    longDescription = ''
      Sway is a tiling Wayland compositor and a drop-in replacement for the i3
      window manager for X11. It works with your existing i3 configuration and
      supports most of i3's features, plus a few extras.
      Sway allows you to arrange your application windows logically, rather
      than spatially. Windows are arranged into a grid by default which
      maximizes the efficiency of your screen and can be quickly manipulated
      using only the keyboard.
    '';

    homepage = "https://swaywm.org";
    changelog = "https://github.com/swaywm/sway/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ c6rg0 ];
    platforms = lib.platforms.linux ++ lib.platforms.freebsd;
    mainProgram = "sway";
  };
})
