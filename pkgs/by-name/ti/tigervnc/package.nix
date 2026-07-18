{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  cmake,
  ffmpeg,
  fltk,
  font-util,
  gawk,
  gettext,
  gnutls,
  libGLU,
  libice,
  libjpeg_turbo,
  libpciaccess,
  libsm,
  libtool,
  libuuid,
  libx11,
  libxdamage,
  libxext,
  libxfont_2,
  libxft,
  libxi,
  libxkbcommon,
  libxkbfile,
  libxrandr,
  libxtst,
  makeWrapper,
  nettle,
  nixosTests,
  openssh,
  pam,
  perl,
  pipewire,
  pixman,
  tab-window-manager,
  util-macros,
  wayland,
  wayland-scanner,
  xauth,
  xkbcomp,
  xkeyboard_config,
  xorg-server,
  xorgproto,
  xsetroot,
  xterm,
  zlib,
  waylandSupport ? stdenv.hostPlatform.isLinux,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tigervnc";
  version = "1.16.2";

  src = fetchFromGitHub {
    owner = "TigerVNC";
    repo = "tigervnc";
    tag = "v${finalAttrs.version}";
    hash = "sha256-yyJCtv48gKftyYND0v18qvh4gimxJt22vxiZBSNZ07U=";
  };

  postPatch =
    lib.optionalString stdenv.hostPlatform.isLinux ''
      sed -i -e '/^\$cmd \.= " -pn";/a$cmd .= " -xkbdir ${xkeyboard_config}/etc/X11/xkb";' unix/vncserver/vncserver.in
      fontPath=
      substituteInPlace vncviewer/vncviewer.cxx \
         --replace-fail '"/usr/bin/ssh' '"${openssh}/bin/ssh'
      source_top="$(pwd)"
    ''
    + ''
      # On Mac, do not build a .dmg, instead copy the .app to the source dir
      gawk -i inplace 'BEGIN { del=0 } /hdiutil/ { del=2 } del<=0 { print } /$VERSION.dmg/ { del -= 1 }' release/makemacapp.in
      echo "mv \"\$APPROOT\" \"\$SRCDIR/\"" >> release/makemacapp.in
    '';

  nativeBuildInputs = [
    cmake
    gettext
    autoconf
    automake
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux (
    [
      font-util
      libtool
      makeWrapper
      util-macros
      zlib
    ]
    ++ xorg-server.nativeBuildInputs
    ++ lib.optionals waylandSupport [
      wayland-scanner
    ]
  );

  buildInputs = [
    fltk
    gnutls
    libjpeg_turbo
    pixman
    gawk
    ffmpeg
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux (
    [
      nettle
      pam
      perl
      xorgproto
      util-macros
      libxtst
      libxext
      libx11
      libxext
      libice
      libxi
      libsm
      libxft
      libxkbfile
      libxfont_2
      libpciaccess
      libGLU
      libxrandr
      libxdamage
    ]
    ++ xorg-server.buildInputs
    ++ lib.optionals waylandSupport [
      libuuid
      libxkbcommon
      pipewire
      wayland
    ]
  );

  propagatedBuildInputs = lib.optionals stdenv.hostPlatform.isLinux xorg-server.propagatedBuildInputs;

  cmakeFlags = [
    (lib.cmakeFeature "CMAKE_INSTALL_PREFIX" (placeholder "out"))
    (lib.cmakeFeature "CMAKE_INSTALL_SBINDIR" "${placeholder "out"}/bin")
    (lib.cmakeFeature "CMAKE_INSTALL_LIBEXECDIR" "${placeholder "out"}/bin")
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    (lib.cmakeBool "ENABLE_WAYLAND" waylandSupport)
  ];

  env.NIX_CFLAGS_COMPILE = toString [
    "-Wno-error=array-bounds"
  ];

  postBuild =
    lib.optionalString stdenv.hostPlatform.isLinux ''
      export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -Wno-error=int-to-pointer-cast -Wno-error=pointer-to-int-cast"
      export CXXFLAGS="$CXXFLAGS -fpermissive"
      # Build Xvnc
      tar xf ${xorg-server.src}
      cp -R xorg*/* unix/xserver
      pushd unix/xserver
      version=$(echo ${xorg-server.name} | sed 's/.*-\([0-9]\+\).[0-9]\+.*/\1/g')
      patch -p1 < "$source_top/unix/xserver$version.patch"
      autoreconf -vfi
      ./configure $configureFlags  --disable-devel-docs --disable-docs \
          --disable-xorg --disable-xnest --disable-xvfb --disable-dmx \
          --disable-xwin --disable-xephyr --disable-kdrive --with-pic \
          --disable-xorgcfg --disable-xprint --disable-static \
          --enable-composite --disable-xtrap --enable-xcsecurity \
          --disable-{a,c,m}fb \
          --disable-xwayland \
          --disable-config-dbus --disable-config-udev --disable-config-hal \
          --disable-xevie \
          --disable-dri --disable-dri2 --disable-dri3 --enable-glx \
          --enable-install-libxf86config \
          --prefix="$out" --disable-unit-tests \
          --with-xkb-path=${xkeyboard_config}/share/X11/xkb \
          --with-xkb-bin-directory=${xkbcomp}/bin \
          --with-xkb-output=$out/share/X11/xkb/compiled
      make TIGERVNC_SRC=$src TIGERVNC_BUILDDIR=`pwd`/../.. -j$NIX_BUILD_CORES
      popd
    ''
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      make dmg
    '';

  postInstall =
    lib.optionalString stdenv.hostPlatform.isLinux ''
      pushd unix/xserver/hw/vnc
      make TIGERVNC_SRC=$src TIGERVNC_BUILDDIR=`pwd`/../../../.. install
      popd
      rm -f $out/lib/xorg/protocol.txt

      wrapProgram $out/bin/vncserver \
        --prefix PATH : ${
          lib.makeBinPath [
            xterm
            tab-window-manager
            xsetroot
            xauth
          ]
        }
    ''
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      mkdir -p $out/Applications
      mv 'TigerVNC Viewer ${finalAttrs.version}.app' $out/Applications/
      rm $out/bin/vncviewer
      echo "#!/usr/bin/env bash
      open $out/Applications/TigerVNC\ Viewer\ ${finalAttrs.version}.app --args \$@" >> $out/bin/vncviewer
      chmod +x $out/bin/vncviewer
    '';

  dontUseCmakeBuildDir = true;
  passthru.tests.tigervnc = nixosTests.tigervnc;

  meta = {
    description = "Fork of tightVNC, made in cooperation with VirtualGL";
    homepage = "https://tigervnc.org/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "vncviewer";
    broken = stdenv.hostPlatform.isDarwin;
    # Prevent a store collision.
    priority = 4;
  };
})
