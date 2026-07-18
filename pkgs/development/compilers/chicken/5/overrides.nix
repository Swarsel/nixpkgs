{
  lib,
  stdenv,
  chickenEggs,
  pkgs,
}:
let
  inherit (lib) addMetaAttrs;
  addToNativeBuildInputs = pkg: old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ lib.toList pkg;
  };
  addToBuildInputs = pkg: old: {
    buildInputs = (old.buildInputs or [ ]) ++ lib.toList pkg;
  };
  addToPropagatedBuildInputs = pkg: old: {
    propagatedBuildInputs = (old.propagatedBuildInputs or [ ]) ++ lib.toList pkg;
  };
  addPkgConfig = old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.pkg-config ];
  };
  addToBuildInputsWithPkgConfig = pkg: old: (addPkgConfig old) // (addToBuildInputs pkg old);
  addToPropagatedBuildInputsWithPkgConfig =
    pkg: old: (addPkgConfig old) // (addToPropagatedBuildInputs pkg old);
  broken = addMetaAttrs { broken = true; };
  brokenOnDarwin = addMetaAttrs { broken = stdenv.hostPlatform.isDarwin; };
  addToCscOptions = opt: old: {
    env.CSC_OPTIONS = lib.concatStringsSep " " ([ old.env.CSC_OPTIONS or "" ] ++ lib.toList opt);
  };
in
{
  # mark broken
  allegro =
    old:
    (broken old)
    // {
      # depends on 'chicken' egg, which doesn't exist, so we specify all the deps here (needs to be
      # kept around even when marked as broken so that evaluation doesn't break due to the missing
      # attribute).
      propagatedBuildInputs = [
        chickenEggs.foreigners
      ];
    };

  blas = addToBuildInputsWithPkgConfig pkgs.blas;
  blosc = addToBuildInputs pkgs.c-blosc;
  botan = broken;
  breadline = addToBuildInputs pkgs.readline;

  cairo =
    old:
    (addToBuildInputsWithPkgConfig pkgs.cairo old)
    // (addToPropagatedBuildInputs (with chickenEggs; [
      srfi-1
      srfi-13
    ]) old);

  canvas-draw = broken;
  cmark = addToBuildInputs pkgs.cmark;
  coops-utils = broken;
  crypt = broken;

  # overrides for chicken 5.4
  dbus =
    old:
    (addToBuildInputsWithPkgConfig [ pkgs.dbus ] old)
    // {
      # backticks in compiler options
      # aren't supported anymore as of chicken 5.4, it seems.
      preBuild = ''
        substituteInPlace \
          dbus.egg dbus.setup \
          --replace '`pkg-config --cflags dbus-1`' "$(pkg-config --cflags dbus-1)" \
          --replace '`pkg-config --libs dbus-1`' "$(pkg-config --libs dbus-1)"
      '';
    };

  ephem = addToBuildInputs pkgs.libnova;

  epoxy =
    old:
    (addToPropagatedBuildInputsWithPkgConfig pkgs.libepoxy old)
    // {
      env.NIX_CFLAGS_COMPILE = toString [
        (
          if stdenv.cc.isClang then
            "-Wno-error=incompatible-function-pointer-types"
          else
            "-Wno-error=incompatible-pointer-types"
        )
        "-Wno-error=int-conversion"
      ];
    };

  espeak = addToBuildInputsWithPkgConfig pkgs.espeak-ng;
  exif = addToBuildInputsWithPkgConfig pkgs.libexif;

  expat =
    old:
    (addToBuildInputsWithPkgConfig pkgs.expat old)
    // {
      env.NIX_CFLAGS_COMPILE = toString [
        (
          if stdenv.cc.isClang then
            "-Wno-error=incompatible-function-pointer-types"
          else
            "-Wno-error=incompatible-pointer-types"
        )
      ];
    };

  ezxdisp =
    old:
    (addToBuildInputsWithPkgConfig pkgs.libx11 old)
    // {
      env.NIX_CFLAGS_COMPILE = toString [
        "-Wno-error=implicit-function-declaration"
      ];
    };

  freetype = addToBuildInputsWithPkgConfig pkgs.freetype;
  # requires fuse2
  fuse = broken;
  gemini = broken;
  gemini-client = broken;

  # less trivial fixes, should be upstreamed
  git =
    old:
    (addToBuildInputsWithPkgConfig pkgs.libgit2 old)
    // {
      postPatch = ''
        substituteInPlace libgit2.scm \
          --replace "asize" "reserved"
      '';
    };

  gl-math = old: {
    env.NIX_CFLAGS_COMPILE = toString [
      "-Wno-error=incompatible-pointer-types"
    ];
  };

  gl-utils = addPkgConfig;
  glfw3 = addToBuildInputsWithPkgConfig pkgs.glfw3;
  glls = addPkgConfig;

  glut =
    old:
    (brokenOnDarwin old)
    // lib.optionalAttrs (!stdenv.hostPlatform.isDarwin) (
      addToCscOptions [
        "-I${(lib.getDev pkgs.libglut)}/include"
        "-I${(lib.getDev pkgs.libGL)}/include"
        "-I${(lib.getDev pkgs.libGLU)}/include"
      ] old
    )
    // (addToBuildInputs pkgs.libglut old);

  hypergiant = broken;
  # mark broken darwin
  # The last successful Darwin Hydra build was in 2024
  iconv = brokenOnDarwin;
  icu = addToBuildInputsWithPkgConfig pkgs.icu;
  imlib2 = addToBuildInputsWithPkgConfig pkgs.imlib2;

  inotify =
    old:
    (addToBuildInputs (lib.optional stdenv.hostPlatform.isDarwin pkgs.libinotify-kqueue) old)
    // lib.optionalAttrs stdenv.hostPlatform.isDarwin (addToCscOptions "-L -linotify" old);

  isaac =
    old:
    (addToBuildInputsWithPkgConfig pkgs.libffi old)
    // {
      postPatch = ''
        substituteInPlace rand.h \
          --replace-fail '/*_ randctx *r, word flag _*/' 'randctx *r, word flag' \
          --replace-fail '/*_ randctx *r _*/' 'randctx *r'
      '';
    };

  iup = broken;
  kiwi = broken;

  lazy-ffi =
    old:
    (addToBuildInputs pkgs.libffi old)
    // {
      postPatch = ''
        substituteInPlace lazy-ffi.scm \
          --replace "ffi/ffi.h" "ffi.h"
      '';
    };

  leveldb = addToBuildInputs pkgs.leveldb;
  libyaml = broken;
  lmdb-ht = broken;
  magic = addToBuildInputs pkgs.file;
  magic-pipes = addToBuildInputs pkgs.chickenPackages_5.chickenEggs.regex;

  math = old: {
    # define-values is used but not imported
    # some breaking change happened now it needs to be done
    # explicitly?
    preBuild = ''
      substituteInPlace *.scm **/*.scm \
        --replace-quiet 'only chicken.base' 'only chicken.base define-values'
    '';
  };

  # requires PCRE
  mdh = broken;
  # missing dependency in upstream egg
  mistie = addToPropagatedBuildInputs (with chickenEggs; [ srfi-1 ]);
  mosquitto = addToPropagatedBuildInputs [ pkgs.mosquitto ];
  mpi = broken;
  nanomsg = addToBuildInputs pkgs.nanomsg;
  ncurses = addToBuildInputsWithPkgConfig [ pkgs.ncurses ];
  oauthtoothy = broken;

  opencl = addToBuildInputs [
    pkgs.opencl-headers
    pkgs.ocl-icd
  ];

  opengl =
    old:
    (brokenOnDarwin old)
    // (addToBuildInputsWithPkgConfig (lib.optionals (!stdenv.hostPlatform.isDarwin) [
      pkgs.libGL
      pkgs.libGLU
    ]) old)
    // {
      postPatch = ''
        substituteInPlace opengl.egg \
          --replace 'framework ' 'framework" "'
      '';
    };

  openssl = addToBuildInputs pkgs.openssl;
  # platform changes
  pledge = addMetaAttrs { platforms = lib.platforms.openbsd; };
  plot = addToBuildInputs pkgs.plotutils;
  # fatal error: 'mqueue.h' file not found
  posix-mq = brokenOnDarwin;

  posix-shm = old: {
    postPatch = lib.optionalString stdenv.hostPlatform.isDarwin ''
      substituteInPlace build.scm \
        --replace "-lrt" ""
    '';
  };

  postgresql = addToBuildInputsWithPkgConfig pkgs.libpq;
  # Undefined symbols for architecture arm64: "_pthread_setschedprio"
  pthreads = brokenOnDarwin;
  pyffi = broken;
  qt-light = broken;
  raylib = addToBuildInputsWithPkgConfig pkgs.raylib;
  rocksdb = addToBuildInputs pkgs.rocksdb_8_3;

  # missing dependency in upstream egg
  s9fes-char-graphics = addToPropagatedBuildInputs (
    with chickenEggs;
    [
      srfi-1
      utf8
      record-variants
    ]
  );

  # missing dependency in upstream egg
  s9fes-char-graphics-shapes = addToPropagatedBuildInputs (
    with chickenEggs;
    [
      utf8
      s9fes-char-graphics
    ]
  );

  schematra-csrf = broken;
  schematra-session = broken;
  scheme2c-compatibility = addPkgConfig;

  sdl-base =
    old:
    (
      (addToPropagatedBuildInputsWithPkgConfig pkgs.SDL old)
      //
        # needed for sdl-config to be in PATH
        (addToNativeBuildInputs pkgs.SDL old)
    );

  sdl2 =
    old:
    (
      (addToPropagatedBuildInputsWithPkgConfig pkgs.SDL2 old)
      //
        # needed for sdl2-config to be in PATH
        (addToNativeBuildInputs pkgs.SDL2 old)
    );

  sdl2-image =
    old:
    (
      (addToPropagatedBuildInputsWithPkgConfig pkgs.SDL2_image old)
      //
        # needed for sdl2-config to be in PATH
        (addToNativeBuildInputs pkgs.SDL2 old)
    );

  sdl2-ttf =
    old:
    (
      (addToPropagatedBuildInputsWithPkgConfig pkgs.SDL2_ttf old)
      //
        # needed for sdl2-config to be in PATH
        (addToNativeBuildInputs pkgs.SDL2 old)
    );

  socket = old: {
    # chicken-do checks for changes to a file that doesn't exist
    preBuild = ''
      touch socket-config
    '';
  };

  soil = addToPropagatedBuildInputsWithPkgConfig pkgs.libepoxy;
  sqlite3 = addToBuildInputs pkgs.sqlite;
  srfi-174 = broken;
  srfi-19 = broken;
  stemmer = old: (addToBuildInputs pkgs.libstemmer old) // (addToCscOptions "-L -lstemmer" old);

  stfl =
    old: (addToBuildInputs [ pkgs.ncurses pkgs.stfl ] old) // (addToCscOptions "-L -lncurses" old);

  # error: use of undeclared identifier 'B4000000'
  stty = brokenOnDarwin;
  sundials = broken;
  svn-client = broken;

  taglib =
    old:
    (addToBuildInputs [ pkgs.zlib pkgs.taglib_1 ] old)
    // (
      # needed for tablib-config to be in PATH
      addToNativeBuildInputs pkgs.taglib_1 old
    );

  tokyocabinet = broken;
  unveil = addMetaAttrs { platforms = lib.platforms.openbsd; };
  uuid-lib = addToBuildInputs pkgs.libuuid;
  # webkitgtk_4_0 was removed
  webview = broken;
  ws-client = addToBuildInputs pkgs.zlib;

  xlib =
    old:
    (addToPropagatedBuildInputs pkgs.libx11 old)
    // {
      env.NIX_CFLAGS_COMPILE = toString [
        (
          if stdenv.cc.isClang then
            "-Wno-error=incompatible-function-pointer-types"
          else
            "-Wno-error=incompatible-pointer-types"
        )
      ];
    };

  yaml = addToBuildInputs pkgs.libyaml;
  zlib = addToBuildInputs pkgs.zlib;
  zmq = addToBuildInputs pkgs.zeromq;
  zstd = addToBuildInputs pkgs.zstd;
}
