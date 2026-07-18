{
  lib,
  stdenv,
  fetchurl,
  bash,
  bdftopcf,
  buildPackages,
  copyDesktopItems,
  coreutils,
  font-adobe-75dpi,
  font-misc-misc,
  groff,
  gzip,
  less,
  libxaw,
  libxext,
  libxpm,
  makeDesktopItem,
  mkfontdir,
  ncurses,
  pkg-config,
  qt5,
  xset,
  qtMode ? false,
  x11Mode ? false,
}:

let
  hint =
    if stdenv.hostPlatform.isLinux then
      "linux.500"
    else if stdenv.hostPlatform.isDarwin then
      "macos.500"
    else
      "unix";
  userDir = "~/.config/nethack";
  binPath = lib.makeBinPath [
    coreutils
    less
  ];

  # The X11 interface loads core X bitmap fonts by XLFD: the "fixed" font for
  # the map and menus (the iso10646-1 variant is used for ENHANCED_SYMBOLS) and
  # adobe "times" for the tombstone. NixOS's X server doesn't have these on its
  # font path by default, so we make the launcher add them at startup, the same
  # way upstream's nethack.sh does for its own bundled font.
  x11FontPath = lib.concatStringsSep "," [
    "${font-misc-misc}/share/fonts/X11/misc"
    "${font-adobe-75dpi}/share/fonts/X11/75dpi"
  ];
in

stdenv.mkDerivation (finalAttrs: {
  pname =
    if x11Mode then
      "nethack-x11"
    else if qtMode then
      "nethack-qt"
    else
      "nethack";

  version = "5.0.0";

  src = fetchurl {
    url = "https://nethack.org/download/${finalAttrs.version}/nethack-${
      lib.replaceStrings [ "." ] [ "" ] finalAttrs.version
    }-src.tgz";

    sha256 = "sha256-KVm3iGqsdhhbkK6gyfgNFDQ/YE3grpaz3Sp2D3qzvek=";
  };

  postPatch = ''
    sed -e '/^ *cd /d' -i sys/unix/nethack.sh
    sed -e '/rm -f $(MAKEDEFS)/d' -i sys/unix/Makefile.src
    sed \
      -e 's,^CFLAGS=-g,CFLAGS=,' \
      -e 's,/bin/gzip,${gzip}/bin/gzip,g' \
      -e 's,^WINTTYLIB=.*,WINTTYLIB=-lncurses,' \
      -e 's,NHCFLAGS+=-DCOMPRESS[^ ]*,NHCFLAGS+=-DCOMPRESS=\\"${gzip}/bin/gzip\\" \\\
        -DCOMPRESS_EXTENSION=\\".gz\\",' \
      -i sys/unix/hints/linux.500
    sed \
      -E 's/^(GDBPATH|GREPPATH)/#\1/' \
      -i sys/unix/sysconf
    sed \
      -e 's,^HACKDIR=.*$,HACKDIR=\$(PREFIX)/games/lib/\$(GAME)dir,' \
      -e 's,^SHELLDIR=.*$,SHELLDIR=\$(PREFIX)/games,' \
      -e 's,^CFLAGS+=-DCRASHREPORT,#CFLAGS+=-DCRASHREPORT,' \
      -e 's,^NHCFLAGS+=-DGREPPATH,#NHCFLAGS+=-DGREPPATH,' \
      -e 's,/usr/bin/true,${coreutils}/bin/true,g' \
      -e 's,NHCFLAGS+=-DCOMPRESS[^ ]*,NHCFLAGS+=-DCOMPRESS=\\"${gzip}/bin/gzip\\" \\\
        -DCOMPRESS_EXTENSION=\\".gz\\",' \
      -i sys/unix/hints/macOS.500
    sed -e '/define CHDIR/d' \
        -i include/config.h
    sed \
      -e 's,AR=.*,AR := $(AR) rcu,' \
      -e 's,RANLIB=.*,RANLIB := $(RANLIB),' \
      -i lib/lua-5.4.8/src/Makefile
    sed \
      -e 's,AR =.*,AR := $(AR),' \
      -i sys/unix/Makefile.src
    ${lib.optionalString qtMode ''
      sed \
        -e 's,^QTDIR *=.*,QTDIR=${qt5.qtbase.dev},' \
        -e 's,PKG_CONFIG_PATH=$(QTDIR)/lib/pkgconfig,,' \
      -i sys/unix/hints/linux.500
      sed \
        -e 's,^endif   # QTDIR,endif   # QTDIR \
              QTDIR=${qt5.qtbase.dev},' \
        -e 's,PKG_CONFIG_PATH=$(QTDIR)/lib/pkgconfig,,' \
        -i sys/unix/hints/macOS.500
    ''}
    ${lib.optionalString (stdenv.buildPlatform != stdenv.hostPlatform)
      # If we're cross-compiling, replace the paths to the data generation tools
      # with the ones from the build platform's nethack package, since we can't
      # run the ones we've built here.
      ''
        sed \
          -e 's, ../util/makedefs,,' \
          -e 's,\t../util/makedefs,\t${buildPackages.nethack}/libexec/nethack/makedefs,' \
          -e 's,\t../util/dlb,\t${buildPackages.nethack}/libexec/nethack/dlb,' \
          -e 's,../util/dlb cf nhdat,${buildPackages.nethack}/libexec/nethack/dlb cf nhdat,' \
          -e 's,pkg-config,$(PKG_CONFIG),' \
          -i sys/unix/Makefile.*
        sed \
          -e 's,pkg-config,$(PKG_CONFIG),' \
          -i sys/unix/hints/linux.500
      ''
    }
  '';

  nativeBuildInputs = [
    copyDesktopItems
    groff
    pkg-config
  ]
  ++ lib.optionals x11Mode [
    mkfontdir
    bdftopcf
  ]
  ++ lib.optionals qtMode [
    mkfontdir
    qt5.qtbase.dev
    qt5.qtmultimedia.dev
    qt5.wrapQtAppsHook
    bdftopcf
  ];

  buildInputs = [
    ncurses
  ]
  ++ lib.optionals x11Mode [
    libxaw
    libxext
    libxpm
  ]
  ++ lib.optionals qtMode [
    gzip
    qt5.qtbase.bin
    qt5.qtmultimedia.bin
  ];

  makeFlags = [
    "PREFIX=$(out)"
    "WANT_WIN_TTY=1"
    "WANT_WIN_CURSES=1"
    "WANT_DEFAULT=curses"
  ]
  ++ lib.optionals x11Mode [
    "WANT_WIN_X11=1"
    "WANT_DEFAULT=X11"
  ]
  ++ lib.optionals qtMode [
    "WANT_WIN_QT=1"
    "WANT_DEFAULT=Qt"
  ];

  postInstall = ''
    mkdir -p $out/games/lib/nethackuserdir
    for i in xlogfile logfile perm record save; do
      mv $out/games/lib/nethackdir/$i $out/games/lib/nethackuserdir
    done

    mkdir -p $out/bin
    cat <<EOF >$out/bin/nethack
    #! ${lib.getExe bash} -e
    PATH=${binPath}:\$PATH

    if [ ! -d ${userDir} ]; then
      mkdir -p ${userDir}
      cp -r $out/games/lib/nethackuserdir/* ${userDir}
      chmod -R +w ${userDir}
    fi

    RUNDIR=\$(mktemp -d)

    cleanup() {
      rm -rf \$RUNDIR${lib.optionalString x11Mode ''

        ${xset}/bin/xset -fp ${x11FontPath} >/dev/null 2>&1 || true''}
    }
    trap cleanup EXIT
    ${lib.optionalString x11Mode ''
      ${xset}/bin/xset +fp ${x11FontPath} >/dev/null 2>&1 || true
      ${xset}/bin/xset fp rehash >/dev/null 2>&1 || true
    ''}
    cd \$RUNDIR
    for i in ${userDir}/*; do
      ln -s \$i \$(basename \$i)
    done
    for i in $out/games/lib/nethackdir/*; do
      ln -s \$i \$(basename \$i)
    done
    set +e
    $out/games/nethack "\$@"
    if [[ \$? -gt 128 ]]; then
      echo "nethack exited abnormally, attempting to recover save file..."
      ./recover -d . ?lock.0
    fi
    EOF
    chmod +x $out/bin/nethack
    ${lib.optionalString x11Mode "mv $out/bin/nethack $out/bin/nethack-x11"}
    ${lib.optionalString qtMode "mv $out/bin/nethack $out/bin/nethack-qt"}
    ${lib.optionalString (!x11Mode && !qtMode && (stdenv.buildPlatform == stdenv.hostPlatform)) ''
      install -Dm 555 util/makedefs -t $out/libexec/nethack/
      install -Dm 555 util/dlb -t $out/libexec/nethack/
    ''}
  '';

  preFixup = lib.optionalString qtMode ''
    wrapQtApp "$out/games/nethack"
  '';

  configurePhase = ''
    pushd sys/unix
    sh setup.sh hints/${hint}
    popd
  '';

  desktopItems = lib.optionals (x11Mode || qtMode) [
    (makeDesktopItem {
      categories = [
        "Game"
        "ActionGame"
      ];

      comment = "NetHack is a single player dungeon exploration game";
      desktopName = "NetHack";

      exec =
        if x11Mode then
          "nethack-x11"
        else if qtMode then
          "nethack-qt"
        else
          "nethack";

      icon = "nethack";
      name = "NetHack";
    })
  ];

  # https://github.com/NixOS/nixpkgs/issues/294751
  enableParallelBuilding = false;

  postUnpack =
    let
      lua548 = fetchurl {
        hash = "sha256-TxjdrhVOeT5G7qtyfFnvHAwMK3ROe5QhlxDXb1MGKa4=";
        url = "https://www.lua.org/ftp/lua-5.4.8.tar.gz";
      };
    in
    ''
      mkdir -p NetHack-${finalAttrs.version}/lib
      tar zxf ${lua548} -C NetHack-${finalAttrs.version}/lib
    '';

  meta = {
    description = "Rogue-like game";
    homepage = "http://nethack.org/";
    license = lib.licenses.ngpl;
    maintainers = with lib.maintainers; [ olduser101 ];
    platforms = lib.platforms.unix;

    mainProgram =
      if x11Mode then
        "nethack-x11"
      else if qtMode then
        "nethack-qt"
      else
        "nethack";
  };
})
