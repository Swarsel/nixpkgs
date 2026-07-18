# xvfb is used by a bunch of things to run tests
# so try to reduce its reverse closure
{
  lib,
  stdenv,
  fetchurl,
  dri-pkgconfig-stub,
  font-util,
  libGL,
  libdrm,
  libx11,
  libxau,
  libxcb,
  libxcb-image,
  libxcb-keysyms,
  libxcb-render-util,
  libxcb-util,
  libxcb-wm,
  libxcvt,
  libxdmcp,
  libxfixes,
  libxfont_2,
  libxkbfile,
  libxshmfence,
  mesa,
  mesa-gl-headers,
  meson,
  ninja,
  openssl,
  pixman,
  pkg-config,
  xkbcomp,
  xkeyboard-config,
  xorg-server,
  xorgproto,
  xtrans,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "xvfb";
  # TODO: commented out for rebuild avoidance after xorg-server update. revert
  # on staging.
  # inherit (xorg-server) src version;
  version = "21.1.23";

  src = fetchurl {
    url = "mirror://xorg/individual/xserver/xorg-server-${finalAttrs.version}.tar.xz";
    hash = "sha256-45gy5WF9ra8HL9+fDhnl0uHCoTYHrCgLrBq6n4/hRjQ=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    font-util
    libGL
    libx11
    libxau
    libxcb
    libxcvt
    libxdmcp
    libxfixes
    libxfont_2
    libxkbfile
    libxshmfence
    mesa-gl-headers
    openssl
    pixman
    libxcb-util
    libxcb-image
    libxcb-keysyms
    libxcb-render-util
    libxcb-wm
    xorgproto
    xtrans
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
    dri-pkgconfig-stub
    libdrm
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    mesa
  ];

  mesonFlags = [
    "-Dxvfb=true"
    "-Dxephyr=false"
    "-Dxorg=false"
    "-Dxnest=false"
    "-Dsecure-rpc=false"
    "-Dudev=false"
    "-Dudev_kms=false"

    "-Dlog_dir=/var/log"
    "-Ddefault_font_path="

    "-Dxkb_bin_dir=${xkbcomp}/bin"
    "-Dxkb_dir=${xkeyboard-config}/share/X11/xkb"
    "-Dxkb_output_dir=$out/share/X11/xkb/compiled"
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
    "-Dxcsecurity=true"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    "-Ddtrace=false"
    "-Dxquartz=false"
  ];

  meta = {
    inherit (xorg-server.meta)
      homepage
      license
      mainProgram
      ;

    description = "X virtual framebuffer";

    longDescription = ''
      Xvfb or X virtual framebuffer is a display server implementing the X11 display server
      protocol. In contrast to other display servers, Xvfb performs all graphical operations in
      virtual memory without showing any screen output. From the point of view of the X client app,
      it acts exactly like any other X display server, serving requests and sending events and
      errors as appropriate. However, no output is shown. This virtual server does not require the
      computer it is running on to have any kind of graphics adapter, a screen or any input device.
      Is is primarily used for testing.
    '';

    platforms = lib.platforms.unix;
  };
})
