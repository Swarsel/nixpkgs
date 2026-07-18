{
  lib,
  stdenv,
  fetchFromGitHub,
  bison,
  buildPackages,
  cairo,
  check,
  flex,
  git,
  glib,
  librsvg,
  libstartup_notification,
  libxcb,
  libxcb-cursor,
  libxcb-keysyms,
  libxcb-util,
  libxcb-wm,
  libxkbcommon,
  meson,
  ninja,
  pandoc,
  pango,
  pkg-config,
  versionCheckHook,
  wayland,
  wayland-protocols,
  wayland-scanner,
  which,
  xcb-imdkit,
  xcbutilxrm,
  waylandSupport ? true,
  x11Support ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rofi-unwrapped";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "davatorium";
    repo = "rofi";
    tag = finalAttrs.version;
    hash = "sha256-akKwIYH9OoCh4ZE/bxKPCppxXsUhplvfRjSGsdthFk4=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    bison
    flex
    meson
    ninja
    pandoc
    pkg-config
  ]
  ++ lib.optionals waylandSupport [
    wayland-protocols
    wayland-scanner
  ];

  buildInputs = [
    cairo
    check
    git
    librsvg
    libstartup_notification
    libxkbcommon
    pango
    which
  ]
  ++ lib.optionals waylandSupport [
    wayland
    wayland-protocols
  ]
  ++ lib.optionals x11Support [
    libxcb
    xcb-imdkit
    libxcb-util
    libxcb-cursor
    libxcb-keysyms
    libxcb-wm
    xcbutilxrm
  ];

  mesonFlags = [
    (lib.mesonBool "imdkit" x11Support)
    (lib.mesonEnable "wayland" waylandSupport)
    (lib.mesonEnable "xcb" x11Support)
  ];

  preConfigure = ''
    patchShebangs "script"
  '';

  doCheck = true;
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  depsBuildBuild = [
    buildPackages.stdenv.cc
    glib
    pkg-config
  ];

  versionCheckProgramArg = "-version";

  meta = {
    description = "Window switcher, run dialog and dmenu replacement";
    homepage = "https://github.com/davatorium/rofi";
    changelog = "https://github.com/davatorium/rofi/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      bew
      SchweGELBin
    ];

    platforms = lib.platforms.linux;
    mainProgram = "rofi";
  };
})
