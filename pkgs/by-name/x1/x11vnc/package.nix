{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  coreutils,
  libjpeg,
  libvncserver,
  libx11,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxinerama,
  libxrandr,
  libxrender,
  libxtst,
  openssl,
  pkg-config,
  xauth,
  xdpyinfo,
  xorgproto,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "x11vnc";
  version = "0.9.17";

  src = fetchFromGitHub {
    owner = "LibVNC";
    repo = "x11vnc";
    tag = finalAttrs.version;
    hash = "sha256-Uc5AzEmfU5kcgfJz4qnry2w6qk/Wzzb/ohho9MnSieM=";
  };

  postPatch = ''
    substituteInPlace src/unixpw.c \
        --replace-fail '"/bin/su"' '"/run/wrappers/bin/su"' \
        --replace-fail '"/bin/true"' '"${coreutils}/bin/true"'

    sed -i -e '/#!\/bin\/sh/a"PATH=${xdpyinfo}\/bin:${xauth}\/bin:$PATH\\n"' -e 's|/bin/su|/run/wrappers/bin/su|g' src/ssltools.h

    # Xdummy script is currently broken, so we avoid building it. This removes everything Xdummy-related from the affected Makefile
    sed -i '/if HAVE_X11/,/endif/d' misc/Makefile.am
  '';

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    libxfixes
    xorgproto
    openssl
    libxdamage
    zlib
    libx11
    libjpeg
    libxtst
    libxinerama
    libxrandr
    libxext
    libxi
    libxrender
    libvncserver
  ];

  meta = {
    description = "VNC server connected to a real X11 screen";
    homepage = "https://github.com/LibVNC/x11vnc/";
    changelog = "https://github.com/LibVNC/x11vnc/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ OPNA2608 ];
    platforms = lib.platforms.linux;
    mainProgram = "x11vnc";
  };
})
