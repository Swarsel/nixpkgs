{
  lib,
  stdenv,
  fetchurl,
  bash,
  dri-pkgconfig-stub,
  egl-wayland,
  epoll-shim,
  evdev-proto,
  font-util,
  gitUpdater,
  libGL,
  libGLU,
  libdecor,
  libdrm,
  libei,
  libepoxy,
  libgbm,
  libtirpc,
  libunwind,
  libx11,
  libxau,
  libxaw,
  libxcb,
  libxcvt,
  libxdmcp,
  libxext,
  libxfixes,
  libxfont_2,
  libxkbfile,
  libxmu,
  libxpm,
  libxrender,
  libxres,
  libxshmfence,
  libxt,
  mesa-gl-headers,
  meson,
  ninja,
  openssl,
  pixman,
  pkg-config,
  systemd,
  wayland,
  wayland-protocols,
  wayland-scanner,
  xkbcomp,
  xkeyboard_config,
  xorgproto,
  xtrans,
  zlib,
  defaultFontPath ? "",
  # Disable withLibunwind as LLVM's libunwind will conflict and does not support the right symbols.
  withLibunwind ? !(stdenv.hostPlatform.useLLVM or false),
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xwayland";
  version = "24.1.13";

  src = fetchurl {
    url = "mirror://xorg/individual/xserver/xwayland-${finalAttrs.version}.tar.xz";
    hash = "sha256-FzrqPW95YJFkwEUo4cjkybYPzVk5HDydrUZnKX1yf7Y=";
  };

  postPatch = ''
    substituteInPlace os/utils.c \
      --replace-fail '/bin/sh' '${lib.getExe' bash "sh"}'
  '';

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    wayland-scanner
  ];

  buildInputs = [
    dri-pkgconfig-stub
    egl-wayland
    libdecor
    libgbm
    libepoxy
    libei
    font-util
    libGL
    libGLU
    libx11
    libxau
    libxaw
    libxdmcp
    libxext
    libxfixes
    libxfont_2
    libxmu
    libxpm
    libxrender
    libxres
    libxt
    libdrm
    libxcb
    libxkbfile
    libxshmfence
    libxcvt
    mesa-gl-headers
    openssl
    pixman
    wayland
    wayland-protocols
    xkbcomp
    xorgproto
    xtrans
    zlib
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    libtirpc
    systemd
  ]
  ++ lib.optionals stdenv.hostPlatform.isFreeBSD [
    epoll-shim
    evdev-proto
  ]
  ++ lib.optionals withLibunwind [
    libunwind
  ];

  mesonFlags = [
    (lib.mesonBool "xcsecurity" true)
    (lib.mesonOption "default_font_path" defaultFontPath)
    (lib.mesonOption "xkb_bin_dir" "${xkbcomp}/bin")
    (lib.mesonOption "xkb_dir" "${xkeyboard_config}/etc/X11/xkb")
    (lib.mesonOption "xkb_output_dir" "${placeholder "out"}/share/X11/xkb/compiled")
    (lib.mesonBool "libunwind" withLibunwind)
  ];

  depsBuildBuild = [
    pkg-config
  ];

  passthru.updateScript = gitUpdater {
    rev-prefix = "xwayland-";
    # No nicer place to find latest release.
    url = "https://gitlab.freedesktop.org/xorg/xserver.git";
  };

  meta = {
    description = "X server for interfacing X11 apps with the Wayland protocol";
    homepage = "https://gitlab.freedesktop.org/xorg/xserver";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      emantor
      k900
    ];

    platforms = lib.platforms.linux ++ lib.platforms.freebsd;
    mainProgram = "Xwayland";
  };
})
