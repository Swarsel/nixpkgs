{
  lib,
  stdenv,
  fetchurl,
  addDriverRunpath,
  adwaita-icon-theme,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  buildPackages,
  cairo,
  coreutils,
  cups,
  dbus,
  dpkg,
  expat,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gsettings-desktop-schemas,
  gtk3,
  gtk4,
  # For GPU acceleration support on Wayland (without the lib it doesn't seem to work)
  libGL,
  libdrm,
  libgbm,
  libkrb5,
  libpulseaudio,
  libuuid,
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
  pipewire,
  qt6,
  snappy,
  udev,
  # Darwin dependencies
  unzip,
  wayland,
  xdg-utils,
  zlib,
  # command line arguments which are always set e.g "--disable-gpu"
  commandLineArgs ? "",
  enableVideoAcceleration ? libvaSupport,
  enableVulkan ? vulkanSupport,
  # For video acceleration via VA-API (--enable-features=AcceleratedVideoDecodeLinuxGL,AcceleratedVideoEncoder)
  libvaSupport ? stdenv.hostPlatform.isLinux,
  # Necessary for USB audio devices.
  pulseSupport ? stdenv.hostPlatform.isLinux,
  # For Vulkan support (--enable-features=Vulkan); disabled by default as it seems to break VA-API
  vulkanSupport ? false,
}:

{
  hash,
  pname,
  url,
  version,
}:

let
  inherit (lib)
    optional
    optionals
    makeLibraryPath
    makeSearchPathOutput
    makeBinPath
    optionalString
    strings
    escapeShellArg
    ;

  deps = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    gtk4
    libdrm
    libx11
    libGL
    libxkbcommon
    libxscrnsaver
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxrandr
    libxrender
    libxshmfence
    libxtst
    libuuid
    libgbm
    nspr
    nss
    pango
    pipewire
    udev
    wayland
    libxcb
    zlib
    snappy
    libkrb5
    qt6.qtbase
  ]
  ++ optional pulseSupport libpulseaudio
  ++ optional libvaSupport libva;

  rpath = makeLibraryPath deps + ":" + makeSearchPathOutput "lib" "lib64" deps;
  binpath = makeBinPath deps;

  enableFeatures =
    optionals enableVideoAcceleration [
      "AcceleratedVideoDecodeLinuxGL"
      "AcceleratedVideoEncoder"
    ]
    ++ optional enableVulkan "Vulkan";

  disableFeatures = [
    "OutdatedBuildDetector"
  ] # disable automatic updates
  # The feature disable is needed for VAAPI to work correctly: https://github.com/brave/brave-browser/issues/20935
  ++ optionals enableVideoAcceleration [ "UseChromeOSDirectVideoDecoder" ];
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    inherit url hash;
  };

  nativeBuildInputs =
    lib.optionals stdenv.hostPlatform.isLinux [
      dpkg
      # override doesn't preserve splicing https://github.com/NixOS/nixpkgs/issues/132651
      # Has to use `makeShellWrapper` from `buildPackages` even though `makeShellWrapper` from the inputs is spliced because `propagatedBuildInputs` would pick the wrong one because of a different offset.
      (buildPackages.wrapGAppsHook3.override { makeWrapper = buildPackages.makeShellWrapper; })
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      unzip
      makeWrapper
    ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    # needed for GSETTINGS_SCHEMAS_PATH
    glib
    gsettings-desktop-schemas
    gtk3
    gtk4

    # needed for XDG_ICON_DIRS
    adwaita-icon-theme
  ];

  installPhase =
    lib.optionalString stdenv.hostPlatform.isLinux ''
      runHook preInstall

      mkdir -p $out $out/bin

      cp -R usr/share $out
      cp -R opt/ $out/opt

      export BINARYWRAPPER=$out/opt/brave.com/brave/brave-browser

      # Fix path to bash in $BINARYWRAPPER
      substituteInPlace $BINARYWRAPPER \
          --replace-fail /bin/bash ${stdenv.shell} \
          --replace-fail 'CHROME_WRAPPER' 'WRAPPER'

      ln -sf $BINARYWRAPPER $out/bin/brave

      for exe in $out/opt/brave.com/brave/{brave,chrome_crashpad_handler}; do
          patchelf \
              --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
              --set-rpath "${rpath}" $exe
      done

      # Fix paths
      substituteInPlace $out/share/applications/{brave-browser,com.brave.Browser}.desktop \
          --replace-fail /usr/bin/brave-browser-stable $out/bin/brave
      substituteInPlace $out/share/gnome-control-center/default-apps/brave-browser.xml \
          --replace-fail /opt/brave.com $out/opt/brave.com
      substituteInPlace $out/opt/brave.com/brave/default-app-block \
          --replace-fail /opt/brave.com $out/opt/brave.com

      # Correct icons location
      icon_sizes=("16" "24" "32" "48" "64" "128" "256")

      for icon in ''${icon_sizes[*]}
      do
          mkdir -p $out/share/icons/hicolor/$icon\x$icon/apps
          ln -s $out/opt/brave.com/brave/product_logo_$icon.png $out/share/icons/hicolor/$icon\x$icon/apps/brave-browser.png
      done

      # Replace xdg-settings and xdg-mime
      ln -sf ${xdg-utils}/bin/xdg-settings $out/opt/brave.com/brave/xdg-settings
      ln -sf ${xdg-utils}/bin/xdg-mime $out/opt/brave.com/brave/xdg-mime

      runHook postInstall
    ''
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      runHook preInstall

      mkdir -p $out/{Applications,bin}

      cp -r . "$out/Applications/Brave Browser.app"

      makeWrapper "$out/Applications/Brave Browser.app/Contents/MacOS/Brave Browser" $out/bin/brave

      runHook postInstall
    '';

  doInstallCheck = stdenv.hostPlatform.isLinux;

  installCheckPhase = ''
    # Bypass upstream wrapper which suppresses errors
    $out/opt/brave.com/brave/brave --version
  '';

  preFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    # Add command line args to wrapGApp.
    gappsWrapperArgs+=(
      --prefix LD_LIBRARY_PATH : ${rpath}
      --prefix PATH : ${binpath}
      --suffix PATH : ${
        lib.makeBinPath [
          xdg-utils
          coreutils
        ]
      }
      --set CHROME_WRAPPER ${pname}
      ${optionalString (enableFeatures != [ ]) ''
        --add-flags "--enable-features=${strings.concatStringsSep "," enableFeatures}\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+,WaylandWindowDecorations --enable-wayland-ime=true}}"
      ''}
      ${optionalString (disableFeatures != [ ]) ''
        --add-flags "--disable-features=${strings.concatStringsSep "," disableFeatures}"
      ''}
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto}}"
      ${optionalString vulkanSupport ''
        --prefix XDG_DATA_DIRS  : "${addDriverRunpath.driverLink}/share"
      ''}
      --add-flags ${escapeShellArg commandLineArgs}
    )
  '';

  dontBuild = true;
  dontConfigure = true;
  dontPatchELF = true;
  passthru.updateScript = ./update.sh;

  meta = {
    description = "Privacy-oriented browser for Desktop and Laptop computers";

    longDescription = ''
      Brave browser blocks the ads and trackers that slow you down,
      chew up your bandwidth, and invade your privacy. Brave lets you
      contribute to your favorite creators automatically.
    '';

    homepage = "https://brave.com/";

    changelog =
      "https://github.com/brave/brave-browser/blob/master/CHANGELOG_DESKTOP.md#"
      + lib.replaceStrings [ "." ] [ "" ] version;

    license = lib.licenses.mpl20;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      uskudnik
      jefflabonte
      nasirhm
      buckley310
    ];

    platforms = [
      "aarch64-linux"
      "x86_64-linux"
      "aarch64-darwin"
    ];

    mainProgram = "brave";
  };
}
