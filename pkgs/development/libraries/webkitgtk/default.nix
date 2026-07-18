{
  lib,
  fetchurl,
  addDriverRunpath,
  at-spi2-core,
  bison,
  bubblewrap,
  cairo,
  clangStdenv,
  cmake,
  enchant,
  expat,
  fetchpatch,
  flite,
  fontconfig,
  freetype,
  geoclue2,
  gettext,
  gi-docgen,
  glib,
  gnutls,
  gobject-introspection,
  gperf,
  gst-plugins-bad,
  gst-plugins-base,
  gtk4,
  harfbuzz,
  hyphen,
  icu,
  lcms2,
  libGL,
  libGLU,
  libavif,
  libbacktrace,
  libedit,
  libepoxy,
  libgbm,
  libgcrypt,
  libgpg-error,
  libidn,
  libintl,
  libjxl,
  libmanette,
  libpthread-stubs,
  librice,
  libseccomp,
  libsecret,
  libsoup_3,
  libsysprof-capture,
  libtasn1,
  libwebp,
  libx11,
  libxkbcommon,
  libxml2,
  libxslt,
  nettle,
  ninja,
  openssl,
  openxr-loader,
  p11-kit,
  perl,
  pkg-config,
  python3,
  readline,
  replaceVars,
  ruby,
  sqlite,
  systemdLibs,
  testers,
  unifdef,
  wayland,
  wayland-protocols,
  wayland-scanner,
  xdg-dbus-proxy,
  enableExperimental ? false,
  enableGeoLocation ? true,
  systemdSupport ? lib.meta.availableOn clangStdenv.hostPlatform systemdLibs,
  withLibsecret ? true,
}:

let
  abiVersion = if lib.versionAtLeast gtk4.version "4.0" then "6.0" else "4.1";
in

# https://webkitgtk.org/2024/10/04/webkitgtk-2.46.html recommends building with clang.
clangStdenv.mkDerivation (finalAttrs: {
  pname = "webkitgtk";
  version = "2.52.5";

  src = fetchurl {
    url = "https://webkitgtk.org/releases/webkitgtk-${finalAttrs.version}.tar.xz";
    hash = "sha256-ilMamr0iFZNuioqRTAd7WGwCKLMdZS8gUoao7JDzNks=";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
  ];

  patches = lib.optionals clangStdenv.hostPlatform.isLinux [
    (replaceVars ./fix-bubblewrap-paths.patch {
      inherit (builtins) storeDir;
      inherit (addDriverRunpath) driverLink;
    })

    # Workaround to fix cross-compilation for RiscV
    # error: ‘toB3Type’ was not declared in this scope
    # See: https://bugs.webkit.org/show_bug.cgi?id=271371
    (fetchpatch {
      hash = "sha256-MgaSpXq9l6KCLQdQyel6bQFHG53l3GY277WePpYXdjA=";
      name = "fix_ftbfs_riscv64.patch";
      url = "https://salsa.debian.org/webkit-team/webkit/-/raw/debian/2.44.1-1/debian/patches/fix-ftbfs-riscv64.patch";
    })
  ];

  postPatch = ''
    patchShebangs .
  '';

  nativeBuildInputs = [
    bison
    cmake
    gettext
    gobject-introspection
    gperf
    ninja
    perl
    perl.pkgs.FileCopyRecursive # used by copy-user-interface-resources.pl
    pkg-config
    python3
    ruby
    gi-docgen
    glib # for gdbus-codegen
    unifdef
  ]
  ++ lib.optionals clangStdenv.hostPlatform.isLinux [
    wayland-scanner
  ];

  buildInputs = [
    at-spi2-core
    cairo # required even when using skia
    enchant
    expat
    flite
    freetype
    libavif
    libepoxy
    libjxl
    gnutls
    gst-plugins-bad
    gst-plugins-base
    harfbuzz
    hyphen
    icu
    libGL
    libGLU
    libgbm
    libgcrypt
    libgpg-error
    libidn
    libintl
    lcms2
    libpthread-stubs
    libsysprof-capture
    libtasn1
    libwebp
    libxkbcommon
    libxml2
    libxslt
    libbacktrace
    nettle
    p11-kit
    sqlite
  ]
  ++ lib.optionals clangStdenv.hostPlatform.isBigEndian [
    # https://bugs.webkit.org/show_bug.cgi?id=274032
    fontconfig
  ]
  ++ lib.optionals clangStdenv.hostPlatform.isDarwin [
    libedit
    readline
  ]
  ++ lib.optionals clangStdenv.hostPlatform.isLinux [
    libseccomp
    libmanette
    wayland
    libx11
  ]
  ++ lib.optionals systemdSupport [
    systemdLibs
  ]
  ++ lib.optionals enableGeoLocation [
    geoclue2
  ]
  ++ lib.optionals enableExperimental [
    # For ENABLE_WEB_RTC
    openssl
    librice
    # For ENABLE_WEBXR
    openxr-loader
  ]
  ++ lib.optionals withLibsecret [
    libsecret
  ]
  ++ lib.optionals (lib.versionAtLeast gtk4.version "4.0") [
    wayland-protocols
  ];

  propagatedBuildInputs = [
    gtk4
    libsoup_3
  ];

  cmakeFlags =
    let
      cmakeBool = x: if x then "ON" else "OFF";
    in
    [
      "-DENABLE_INTROSPECTION=ON"
      "-DPORT=GTK"
      "-DUSE_LIBSECRET=${cmakeBool withLibsecret}"
      "-DENABLE_EXPERIMENTAL_FEATURES=${cmakeBool enableExperimental}"
    ]
    ++ lib.optionals clangStdenv.hostPlatform.isLinux [
      # Have to be explicitly specified when cross.
      # https://github.com/WebKit/WebKit/commit/a84036c6d1d66d723f217a4c29eee76f2039a353
      "-DBWRAP_EXECUTABLE=${lib.getExe bubblewrap}"
      "-DDBUS_PROXY_EXECUTABLE=${lib.getExe xdg-dbus-proxy}"
    ]
    ++ lib.optionals clangStdenv.hostPlatform.isDarwin [
      "-DENABLE_GAMEPAD=OFF"
      "-DENABLE_GTKDOC=OFF"
      "-DENABLE_MINIBROWSER=OFF"
      "-DENABLE_QUARTZ_TARGET=ON"
      "-DENABLE_X11_TARGET=OFF"
      "-DUSE_APPLE_ICU=OFF"
      "-DUSE_OPENGL_OR_ES=OFF"
    ]
    ++ lib.optionals (lib.versionOlder gtk4.version "4.0") [
      "-DUSE_GTK4=OFF"
    ]
    ++ lib.optionals (!systemdSupport) [
      "-DENABLE_JOURNALD_LOG=OFF"
    ];

  postFixup = ''
    # Cannot be in postInstall, otherwise _multioutDocs hook in preFixup will move right back.
    moveToOutput "share/doc" "$devdoc"
  '';

  name = "webkitgtk-${finalAttrs.version}+abi=${abiVersion}";
  requiredSystemFeatures = [ "big-parallel" ];
  # https://github.com/NixOS/nixpkgs/issues/153528
  # Can't be linked within a 4GB address space.
  separateDebugInfo = clangStdenv.hostPlatform.isLinux && !clangStdenv.hostPlatform.is32bit;
  passthru.tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

  meta = {
    description = "Web content rendering engine, GTK port";
    homepage = "https://webkitgtk.org/";
    license = lib.licenses.bsd2;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "WebKitWebDriver";
    broken = clangStdenv.hostPlatform.isDarwin;

    pkgConfigModules =
      if lib.versionAtLeast abiVersion "6.0" then
        [
          "javascriptcoregtk-${abiVersion}"
          "webkitgtk-${abiVersion}"
          "webkitgtk-web-process-extension-${abiVersion}"
        ]
      else
        [
          "javascriptcoregtk-${abiVersion}"
          "webkit2gtk-${abiVersion}"
          "webkit2gtk-web-extension-${abiVersion}"
        ];

    teams = [ lib.teams.gnome ];
  };
})
