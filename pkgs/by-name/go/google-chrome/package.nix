{
  lib,
  fetchurl,
  # For Vulkan support (--enable-features=Vulkan)
  addDriverRunpath,
  adwaita-icon-theme,
  # Linked dynamic libraries.
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  bintools,
  ## Gentoo
  bzip2,
  cairo,
  # Command line programs
  coreutils,
  cups,
  # Additional dependencies according to other distros.
  ## Ubuntu
  curl,
  dbus,
  expat,
  ## Arch Linux.
  flac,
  fontconfig,
  freetype,
  gcc-unwrapped,
  gdk-pixbuf,
  glib,
  gsettings-desktop-schemas,
  gtk3,
  gtk4,
  harfbuzz,
  icu,
  kdePackages,
  libcap,
  libdrm,
  liberation_ttf,
  # Loaded at runtime.
  libexif,
  libgbm,
  libglvnd,
  libkrb5,
  libopus,
  libpng,
  # Necessary for USB audio devices.
  libpulseaudio,
  # For video acceleration via VA-API (--enable-features=VaapiVideoDecoder)
  libva,
  libx11,
  libxcb,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxkbcommon,
  libxrandr,
  libxrender,
  libxscrnsaver,
  libxshmfence,
  libxtst,
  makeWrapper,
  nspr,
  nss,
  pango,
  patchelf,
  pciutils,
  pipewire,
  qt6,
  snappy,
  speechd-minimal,
  stdenvNoCC,
  # Will crash without.
  systemd,
  undmg,
  util-linux,
  vulkan-loader,
  wayland, # ozone/wayland
  wget,
  xdg-utils,
  # command line arguments which are always set e.g "--disable-gpu"
  commandLineArgs ? "",
  libvaSupport ? true,
  # Enables Chrome's "Use QT" appearance to introspect the user's Plasma theme
  plasmaSupport ? false,
  pulseSupport ? true,
  # Create a symlink at $out/bin/google-chrome
  withSymlink ? true,
}:

let
  pname = "google-chrome";

  opusWithCustomModes = libopus.override { withCustomModes = true; };

  deps = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    bzip2
    cairo
    coreutils
    cups
    curl
    dbus
    expat
    flac
    fontconfig
    freetype
    gcc-unwrapped.lib
    gdk-pixbuf
    glib
    harfbuzz
    icu
    libcap
    libdrm
    liberation_ttf
    libexif
    libglvnd
    libkrb5
    libpng
    libx11
    libxcb
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxkbcommon
    libxrandr
    libxrender
    libxscrnsaver
    libxshmfence
    libxtst
    libgbm
    nspr
    nss
    opusWithCustomModes
    pango
    pciutils
    pipewire
    snappy
    speechd-minimal
    systemd
    util-linux
    vulkan-loader
    wayland
    wget
  ]
  ++ lib.optional pulseSupport libpulseaudio
  ++ lib.optional libvaSupport libva
  ++ [
    gtk3
    gtk4
  ]
  ++ lib.optionals plasmaSupport [
    qt6.qtbase
    qt6.qtwayland
    kdePackages.plasma-integration
    kdePackages.breeze
  ];

  linux = stdenvNoCC.mkDerivation (finalAttrs: {
    inherit pname meta passthru;
    version = "150.0.7871.124";

    src = fetchurl {
      url = "https://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_${finalAttrs.version}-1_amd64.deb";
      hash = "sha256-TGNqvSrB9vMXb1K7QBCqN9ErWsBMQNyp6rEZksHHXNw=";
    };

    # With strictDeps on, some shebangs were not being patched correctly
    # ie, $out/share/google/chrome/google-chrome
    strictDeps = false;

    nativeBuildInputs = [
      makeWrapper
      patchelf
    ];

    buildInputs = [
      # needed for XDG_ICON_DIRS
      adwaita-icon-theme
      glib
      gtk3
      gtk4
      # needed for GSETTINGS_SCHEMAS_PATH
      gsettings-desktop-schemas
    ];

    installPhase = ''
      runHook preInstall

      appname=chrome
      dist=stable

      exe=$out/bin/google-chrome-$dist

      mkdir -p $out/bin $out/share
      cp -v -a opt/* $out/share
      cp -v -a usr/share/* $out/share

      # replace bundled vulkan-loader
      rm -v $out/share/google/$appname/libvulkan.so.1
      ln -v -s -t "$out/share/google/$appname" "${lib.getLib vulkan-loader}/lib/libvulkan.so.1"

      substituteInPlace $out/share/google/$appname/google-$appname \
        --replace-fail 'CHROME_WRAPPER' 'WRAPPER'
      substituteInPlace $out/share/applications/com.google.Chrome.desktop \
        --replace-fail /usr/bin/google-chrome-$dist $exe
      substituteInPlace $out/share/applications/google-$appname.desktop \
        --replace-fail /usr/bin/google-chrome-$dist $exe
      substituteInPlace $out/share/gnome-control-center/default-apps/google-$appname.xml \
        --replace-fail /opt/google/$appname/google-$appname $exe

      for icon_file in $out/share/google/chrome*/product_logo_[0-9]*.png; do
        num_and_suffix="''${icon_file##*logo_}"
        if [ $dist = "stable" ]; then
          icon_size="''${num_and_suffix%.*}"
        else
          icon_size="''${num_and_suffix%_*}"
        fi
        logo_output_prefix="$out/share/icons/hicolor"
        logo_output_path="$logo_output_prefix/''${icon_size}x''${icon_size}/apps"
        mkdir -p "$logo_output_path"
        mv "$icon_file" "$logo_output_path/google-$appname.png"
      done

      # "--simulate-outdated-no-au" disables auto updates and browser outdated popup
      makeWrapper "$out/share/google/$appname/google-$appname" "$exe" \
        ${lib.optionalString plasmaSupport ''
          --prefix QT_PLUGIN_PATH  : "${qt6.qtbase}/lib/qt-6/plugins" \
          --prefix QT_PLUGIN_PATH  : "${qt6.qtwayland}/lib/qt-6/plugins" \
          --prefix QT_PLUGIN_PATH  : "${kdePackages.plasma-integration}/lib/qt-6/plugins" \
          --prefix QT_PLUGIN_PATH  : "${kdePackages.breeze}/lib/qt-6/plugins" \
          --prefix NIXPKGS_QT6_QML_IMPORT_PATH : "${qt6.qtwayland}/lib/qt-6/qml" \
        ''} \
        --prefix LD_LIBRARY_PATH : "$rpath" \
        --prefix PATH            : "$binpath" \
        --suffix PATH            : "${lib.makeBinPath [ xdg-utils ]}" \
        --prefix XDG_DATA_DIRS   : "$XDG_ICON_DIRS:$GSETTINGS_SCHEMAS_PATH:${addDriverRunpath.driverLink}/share" \
        --set CHROME_WRAPPER  "google-chrome-$dist" \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
        --add-flags "--simulate-outdated-no-au='Tue, 31 Dec 2099 23:59:59 GMT'" \
        --add-flags ${lib.escapeShellArg commandLineArgs}

      # Make sure that libGL and libvulkan are found by ANGLE libGLESv2.so
      patchelf --set-rpath $rpath $out/share/google/$appname/lib*GL*

      for elf in $out/share/google/$appname/{chrome,chrome-sandbox,chrome_crashpad_handler}; do
        patchelf --set-rpath $rpath $elf
        patchelf --set-interpreter ${bintools.dynamicLinker} $elf
      done

      runHook postInstall
    '';

    postInstall = lib.optionalString withSymlink ''
      ln -s $out/bin/google-chrome-stable $out/bin/google-chrome
    '';

    binpath = lib.makeBinPath deps;
    rpath = lib.makeLibraryPath deps + ":" + lib.makeSearchPathOutput "lib" "lib64" deps;

    unpackPhase = ''
      runHook preUnpack
      ${lib.getExe' bintools "ar"} x $src
      tar xf data.tar.xz
      runHook postUnpack
    '';
  });

  darwin = stdenvNoCC.mkDerivation (finalAttrs: {
    inherit pname meta passthru;
    version = "150.0.7871.125";

    src = fetchurl {
      url = "http://dl.google.com/release2/chrome/kjpfr4hhda65lyoxi6u4o42bke_150.0.7871.125/GoogleChrome-150.0.7871.125.dmg";
      hash = "sha256-ulMe+AP65d9VB2O7vhLnSX+dUfC7XqWd4GaOEQXGBac=";
    };

    nativeBuildInputs = [
      makeWrapper
      undmg
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/Applications
      cp -r *.app $out/Applications

      mkdir -p $out/bin

      # "--simulate-outdated-no-au" disables auto updates and browser outdated popup
      makeWrapper $out/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome $out/bin/google-chrome-stable \
        --add-flags "--simulate-outdated-no-au='Tue, 31 Dec 2099 23:59:59 GMT'" \
        --add-flags ${lib.escapeShellArg commandLineArgs}
      runHook postInstall
    '';

    postInstall = lib.optionalString withSymlink ''
      ln -s $out/bin/google-chrome-stable $out/bin/google-chrome
    '';

    dontBuild = true;
    dontConfigure = true;
    dontFixup = true;
    dontPatch = true;
    sourceRoot = ".";
  });

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Freeware web browser developed by Google";
    homepage = "https://www.google.com/chrome/browser/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      iedame
      mdaniels5757
    ];

    platforms = lib.platforms.darwin ++ [ "x86_64-linux" ];
    mainProgram = "google-chrome-stable";
  };
in
if stdenvNoCC.hostPlatform.isDarwin then
  darwin
else if stdenvNoCC.hostPlatform.isLinux then
  linux
else
  throw "Unsupported platform ${stdenvNoCC.hostPlatform.system}"
