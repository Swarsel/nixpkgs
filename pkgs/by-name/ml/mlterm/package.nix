{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2, # for the "sdl" --with-gui option
  autoconf,
  cairo,
  fcitx5,
  fcitx5-gtk,
  fetchpatch,
  fribidi,
  gdk-pixbuf,
  gtk3,
  harfbuzz, # can be replaced with libotf
  ibus,
  libssh2, # build-in ssh
  libx11,
  libxft,
  libxkbcommon,
  m17n_lib,
  makeDesktopItem,
  nixosTests,
  pkg-config,
  uim, # IME
  vte,
  wayland, # for the "wayland" --with-gui option
  wrapGAppsHook3, # color picker in mlconfig
  # Configure the Exec directive in the generated .desktop file
  desktopBinary ? (
    if enableGuis.xlib then
      "mlterm"
    else if enableGuis.wayland then
      "mlterm-wl"
    else if enableGuis.sdl2 then
      "mlterm-sdl2"
    else
      throw "mlterm: couldn't figure out what desktopBinary to use."
  ),
  # Most of the input methods and other build features are enabled by default,
  # the following attribute set can be used to disable some of them. It's parsed
  # when we set `configureFlags`. If you find other configure Flags that require
  # dependencies, it'd be nice to make that contribution here.
  enableFeatures ? {
    bidi = true;
    fcitx = !stdenv.hostPlatform.isDarwin;
    ibus = !stdenv.hostPlatform.isDarwin;
    m17n = !stdenv.hostPlatform.isDarwin;
    # Open Type layout support, (substituting glyphs with opentype fonts)
    otl = true;
    ssh2 = true;
    uim = !stdenv.hostPlatform.isDarwin;
  },
  # List of gui libraries to use. According to `./configure --help` ran on
  # release 3.9.3, options are: (xlib|win32|fb|quartz|console|wayland|sdl2|beos)
  enableGuis ? {
    # From some reason, upstream's ./configure script disables compilation of the
    # external tool `mlconfig` if `enableGuis.fb == true`. This behavior is not
    # documentd in `./configure --help`, and it is reported here:
    # https://github.com/arakiken/mlterm/issues/73
    fb = false;
    quartz = stdenv.hostPlatform.isDarwin;
    sdl2 = true;
    wayland = stdenv.hostPlatform.isLinux;
    xlib = enableX11;
  },
  # List of external tools to create, this default list includes all default
  # tools, as recorded on release 3.9.3.
  enableTools ? {
    mlcc = true;
    mlclient = true;
    mlconfig = true;
    mlfc = true;
    # Note that according to upstream's ./configure script, to disable
    # mlimgloader you have to disable _all_ tools. See:
    # https://github.com/arakiken/mlterm/issues/69
    mlimgloader = true;
    mlterm-menu = true;
    registobmp = true;
  },
  # List of typing engines, the default list enables compiling all of the
  # available ones, as recorded on release 3.9.3
  enableTypeEngines ? {
    cairo = true;
    xcore = false; # Considered legacy
    xft = enableX11;
  },
  # Whether to enable the X window system
  enableX11 ? stdenv.hostPlatform.isLinux,
  gtk ? gtk3,
}:

let
  # Returns a --with-feature=<comma separated string list of all `true`
  # attributes>, or `--without-feature` if all attributes are false or don't
  # exist. Used later in configureFlags
  withFeaturesList =
    featureName: attrset:
    let
      commaSepList = lib.concatStringsSep "," (builtins.attrNames (lib.filterAttrs (n: v: v) attrset));
    in
    lib.withFeatureAs (commaSepList != "") featureName commaSepList;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "mlterm";
  version = "3.9.4";

  src = fetchFromGitHub {
    owner = "arakiken";
    repo = "mlterm";
    tag = finalAttrs.version;
    sha256 = "sha256-YogapVTmW4HAyVgvhR4ZvW4Q6v0kGiW11CCxN6SpPCY=";
  };

  patches = [
    (fetchpatch {
      excludes = [
        "ChangeLog"
      ];

      hash = "sha256-xI0CzXN3gfXZXrL1/tFgQDtpY5hnzGLPruidOuMrbPQ=";
      url = "https://github.com/arakiken/mlterm/commit/819366f9c3c015d1be501d626ca954ce3ce38a60.patch";
    })
  ];

  nativeBuildInputs = [
    pkg-config
    autoconf
  ]
  ++ lib.optionals enableTools.mlconfig [
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk
    vte
    gdk-pixbuf
  ]
  ++ lib.optionals enableTypeEngines.xcore [
    libx11
  ]
  ++ lib.optionals enableTypeEngines.xft [
    libxft
  ]
  ++ lib.optionals enableTypeEngines.cairo [
    cairo
  ]
  ++ lib.optionals enableGuis.wayland [
    libxkbcommon
    wayland
  ]
  ++ lib.optionals enableGuis.sdl2 [
    SDL2
  ]
  ++ lib.optionals enableFeatures.otl [
    harfbuzz
  ]
  ++ lib.optionals enableFeatures.bidi [
    fribidi
  ]
  ++ lib.optionals enableFeatures.ssh2 [
    libssh2
  ]
  ++ lib.optionals enableFeatures.m17n [
    m17n_lib
  ]
  ++ lib.optionals enableFeatures.fcitx [
    fcitx5
    fcitx5-gtk
  ]
  ++ lib.optionals enableFeatures.ibus [
    ibus
  ]
  ++ lib.optionals enableFeatures.uim [
    uim
  ];

  configureFlags = [
    (withFeaturesList "type-engines" enableTypeEngines)
    (withFeaturesList "tools" enableTools)
    (withFeaturesList "gui" enableGuis)
    (lib.withFeature enableX11 "x")
  ]
  ++ lib.optionals (gtk != null) [
    "--with-gtk=${lib.versions.major gtk.version}.0"
  ]
  ++ (lib.mapAttrsToList (n: v: lib.enableFeature v n) enableFeatures)
  ++ [
  ];

  env = {
    NIX_CFLAGS_COMPILE =
      # GCC15 defaults to C23 which is stricter about prototypes
      # There are upstream fixes, but they are not in 3.9.4 release
      lib.optionalString stdenv.cc.isGNU " -std=c17 ";
  };

  postInstall = ''
    install -D contrib/icon/mlterm-icon.svg "$out/share/icons/hicolor/scalable/apps/mlterm.svg"
    install -D contrib/icon/mlterm-icon-gnome2.png "$out/share/icons/hicolor/48x48/apps/mlterm.png"
    install -D -t $out/share/applications $desktopItem/share/applications/*
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir -p $out/Applications/
    cp -a cocoa/mlterm.app $out/Applications/
    install $out/bin/mlterm -Dt $out/Applications/mlterm.app/Contents/MacOS/
  '';

  desktopItem = makeDesktopItem {
    categories = [
      "System"
      "TerminalEmulator"
    ];

    comment = "Multi Lingual TERMinal emulator";
    desktopName = "mlterm";
    exec = "${desktopBinary} %U";
    genericName = "Terminal emulator";
    icon = "mlterm";
    name = "mlterm";
    startupNotify = false;
    type = "Application";
  };

  enableParallelBuilding = true;

  passthru = {
    inherit
      enableTypeEngines
      enableTools
      enableGuis
      enableFeatures
      ;

    tests.test = nixosTests.terminal-emulators.mlterm;
  };

  meta = {
    description = "Multi Lingual TERMinal emulator";
    homepage = "https://mlterm.sourceforge.net/";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      ramkromberg
      atemu
      doronbehar
    ];

    platforms = lib.platforms.all;
    mainProgram = desktopBinary;
  };
})
