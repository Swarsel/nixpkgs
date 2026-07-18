{
  lib,
  stdenv,
  arcan,
  audit,
  dbus,
  dri-pkgconfig-stub,
  fetchFromCodeberg,
  font-util,
  libGL,
  libdrm,
  libepoxy,
  libgbm,
  libgcrypt,
  libmd,
  libselinux,
  libtirpc,
  libx11,
  libxau,
  libxcb,
  libxcb-image,
  libxcb-util,
  libxcb-wm,
  libxdmcp,
  libxfont_2,
  libxkbfile,
  libxshmfence,
  mesa-gl-headers,
  meson,
  nettle,
  ninja,
  openssl,
  pixman,
  pkg-config,
  systemd,
  unstableGitUpdater,
  xkbcomp,
  xkeyboard_config,
  xorgproto,
  xtrans,
}:

stdenv.mkDerivation (finalPackages: rec {
  pname = "xarcan";
  version = "0.7.1";

  src = fetchFromCodeberg {
    owner = "letoram";
    repo = "xarcan";
    tag = version;
    hash = "sha256-j20Wz/Ae4QTincAPgMoj19EfKAPxIGm0Jgmi4sUR88o=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    arcan
    audit
    dbus
    dri-pkgconfig-stub
    libepoxy
    font-util
    libGL
    libx11
    libxau
    libxdmcp
    libxfont_2
    libdrm
    libgcrypt
    libmd
    libselinux
    libtirpc
    libxcb
    libxkbfile
    libxshmfence
    libgbm
    mesa-gl-headers
    nettle
    openssl
    pixman
    systemd
    libxcb-util
    libxcb-wm
    libxcb-image
    xkbcomp
    xkeyboard_config
    xorgproto
    xtrans
  ];

  configureFlags = [
    "--disable-int10-module"
    "--disable-static"
    "--disable-xnest"
    "--disable-xorg"
    "--disable-xvfb"
    "--disable-xwayland"
    "--enable-glamor"
    "--enable-glx"
    "--enable-ipv6"
    "--enable-kdrive"
    "--enable-record"
    "--enable-xarcan"
    "--enable-xcsecurity"
    "--with-xkb-bin-directory=${xkbcomp}/bin"
    "--with-xkb-output=/tmp"
    "--with-xkb-path=${xkeyboard_config}/share/X11/xkb"
  ];

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Patched Xserver that bridges connections to Arcan";

    longDescription = ''
      xarcan is a patched X server with a KDrive backend that uses the
      arcan-shmif to map Xlib/Xcb/X clients to a running arcan instance. It
      allows running an X session as a window under Arcan.
    '';

    homepage = "https://codeberg.org/letoram/xarcan";
    license = with lib.licenses; [ mit ];
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "Xarcan";
  };
})
