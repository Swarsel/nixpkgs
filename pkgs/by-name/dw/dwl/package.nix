{
  lib,
  stdenv,
  fetchFromCodeberg,
  installShellFiles,
  libinput,
  libx11,
  libxcb,
  libxcb-wm,
  libxkbcommon,
  nixosTests,
  pixman,
  pkg-config,
  testers,
  wayland,
  wayland-protocols,
  wayland-scanner,
  wlroots_0_19,
  writeText,
  xwayland,
  # Deprecated options
  # Remove them before next version of either Nixpkgs or dwl itself
  conf ? null,
  # Configurable options
  configH ?
    if conf != null then
      lib.warn ''
        conf parameter is deprecated;
        use configH instead
      '' conf
    else
      null,
  # Boolean flags
  enableXWayland ? true,
  withCustomConfigH ? (configH != null),
}:

# If we set withCustomConfigH, let's not forget configH
assert withCustomConfigH -> (configH != null);
stdenv.mkDerivation (finalAttrs: {
  pname = "dwl";
  version = "0.8";

  src = fetchFromCodeberg {
    owner = "dwl";
    repo = "dwl";
    rev = "v${finalAttrs.version}";
    hash = "sha256-J76L5ZOCYgfcY08wH5cSLG+UdgDrv50lQyEnJNqDkXI=";
  };

  outputs = [
    "out"
    "man"
  ];

  postPatch =
    let
      configFile =
        if lib.isDerivation configH || builtins.isPath configH then
          configH
        else
          writeText "config.h" configH;
    in
    lib.optionalString withCustomConfigH "cp ${configFile} config.h";

  strictDeps = true;

  nativeBuildInputs = [
    installShellFiles
    pkg-config
    wayland-scanner
  ];

  buildInputs = [
    libinput
    libxcb
    libxkbcommon
    pixman
    wayland
    wayland-protocols
    wlroots_0_19
  ]
  ++ lib.optionals enableXWayland [
    libx11
    libxcb-wm
    xwayland
  ];

  makeFlags = [
    "PKG_CONFIG=${stdenv.cc.targetPrefix}pkg-config"
    "WAYLAND_SCANNER=wayland-scanner"
    "PREFIX=$(out)"
    "MANDIR=$(man)/share/man"
  ]
  ++ lib.optionals enableXWayland [
    ''XWAYLAND="-DXWAYLAND"''
    ''XLIBS="xcb xcb-icccm"''
  ];

  # required for whitespaces in makeFlags
  __structuredAttrs = true;

  passthru = {
    tests = {
      version = testers.testVersion {
        # `dwl -v` emits its version string to stderr and returns 1
        command = "dwl -v 2>&1; return 0";
        package = finalAttrs.finalPackage;
      };

      basic = nixosTests.dwl;
    };
  };

  meta = {
    inherit (wayland.meta) platforms;
    description = "Dynamic window manager for Wayland";

    longDescription = ''
      dwl is a compact, hackable compositor for Wayland based on wlroots. It is
      intended to fill the same space in the Wayland world that dwm does in X11,
      primarily in terms of philosophy, and secondarily in terms of
      functionality. Like dwm, dwl is:

      - Easy to understand, hack on, and extend with patches
      - One C source file (or a very small number) configurable via config.h
      - Tied to as few external dependencies as possible
    '';

    homepage = "https://codeberg.org/dwl/dwl";
    changelog = "https://codeberg.org/dwl/dwl/src/branch/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    mainProgram = "dwl";
  };
})
# TODO: custom patches from upstream website
