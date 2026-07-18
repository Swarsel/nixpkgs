{
  lib,
  stdenv,
  fetchFromGitHub,
  cjson,
  libGL,
  libinput,
  libx11,
  libxcb,
  libxcb-wm,
  libxkbcommon,
  meson,
  ninja,
  pcre2,
  pixman,
  pkg-config,
  scenefx,
  wayland,
  wayland-protocols,
  wayland-scanner,
  wlroots_0_19,
  xwayland,
  enableXWayland ? true,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "mango";
  version = "0.14.4";

  src = fetchFromGitHub {
    owner = "mangowm";
    repo = "mango";
    tag = finalAttrs.version;
    hash = "sha256-WfQNALT+8ZbjZG2co1tz2dZZZw1tcU5ynuFe+vVMbV0=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wayland-scanner
  ];

  buildInputs = [
    cjson
    libinput
    libxcb
    libxkbcommon
    pcre2
    pixman
    wayland
    wayland-protocols
    wlroots_0_19
    scenefx
    libGL
  ]
  ++ lib.optionals enableXWayland [
    libx11
    libxcb-wm
    xwayland
  ];

  mesonFlags = [
    (lib.mesonEnable "xwayland" enableXWayland)
  ];

  __structuredAttrs = true;

  passthru = {
    providedSessions = [
      "mango"
    ];
  };

  meta = {
    description = "Lightweight and feature-rich Wayland compositor based on dwl";
    homepage = "https://mangowm.github.io";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      hustlerone
      yvnth
    ];

    platforms = lib.platforms.linux;
    mainProgram = "mango";
  };
})
