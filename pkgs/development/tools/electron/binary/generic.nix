{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  at-spi2-atk,
  cairo,
  cups,
  dbus,
  expat,
  fetchzip,
  gdk-pixbuf,
  glib,
  gtk3,
  gtk4,
  libGL,
  libdrm,
  libgbm,
  libnotify,
  libpulseaudio,
  libsecret,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxkbcommon,
  libxkbfile,
  libxrandr,
  libxshmfence,
  makeWrapper,
  nspr,
  nss,
  pango,
  pciutils,
  pipewire,
  speechd-minimal,
  systemd,
  unzip,
  vulkan-loader,
  wrapGAppsHook3,
}:

version: hashes:
let
  pname = "electron";

  meta = {
    description = "Cross platform desktop application shell";
    homepage = "https://github.com/electron/electron";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    platforms = [
      "x86_64-linux"
      "armv7l-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    mainProgram = "electron";
    # https://www.electronjs.org/docs/latest/tutorial/electron-timelines
    knownVulnerabilities = lib.optional (lib.versionOlder version "41.0.0") "Electron version ${version} is EOL";
    teams = [ lib.teams.electron ];
  };

  fetcher =
    vers: tag: hash:
    fetchurl {
      sha256 = hash;
      url = "https://github.com/electron/electron/releases/download/v${vers}/electron-v${vers}-${tag}.zip";
    };

  headersFetcher =
    vers: hash:
    fetchzip {
      name = "electron-${vers}-headers";
      sha256 = hash;
      url = "https://artifacts.electronjs.org/headers/dist/v${vers}/node-v${vers}-headers.tar.gz";
    };

  tags = {
    aarch64-darwin = "darwin-arm64";
    aarch64-linux = "linux-arm64";
    armv7l-linux = "linux-armv7l";
    x86_64-linux = "linux-x64";
  };

  get = as: platform: as.${platform.system} or (throw "Unsupported system: ${platform.system}");

  common = platform: {
    inherit pname version meta;
    src = fetcher version (get tags platform) (get hashes platform);
    passthru.headers = headersFetcher version hashes.headers;
  };

  electronLibPath = lib.makeLibraryPath [
    alsa-lib
    at-spi2-atk
    cairo
    cups
    dbus
    expat
    gdk-pixbuf
    glib
    gtk3
    gtk4
    nss
    nspr
    libx11
    libxcb
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxkbfile
    pango
    pciutils
    stdenv.cc.cc
    systemd
    libnotify
    pipewire
    libsecret
    libpulseaudio
    speechd-minimal
    libdrm
    libgbm
    libxkbcommon
    libxshmfence
    libGL
    vulkan-loader
  ];

  linux = finalAttrs: {
    strictDeps = true;

    nativeBuildInputs = [
      unzip
      makeWrapper
      wrapGAppsHook3
    ];

    buildInputs = [
      glib
      gtk3
      gtk4
    ];

    installPhase = ''
      mkdir -p $out/libexec/electron
      unzip -d $out/libexec/electron $src
      chmod u-x $out/libexec/electron/*.so*
    '';

    preFixup = ''
      makeWrapper "$out/libexec/electron/electron" $out/bin/electron \
        "''${gappsWrapperArgs[@]}"
    '';

    postFixup = ''
      patchelf \
        --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        --set-rpath "${electronLibPath}:$out/libexec/electron" \
        $out/libexec/electron/electron \
        $out/libexec/electron/chrome_crashpad_handler

      # patch libANGLE
      patchelf \
        --set-rpath "${
          lib.makeLibraryPath [
            libGL
            pciutils
            vulkan-loader
          ]
        }" \
        $out/libexec/electron/lib*GL*

      # replace bundled vulkan-loader
      rm "$out/libexec/electron/libvulkan.so.1"
      ln -s -t "$out/libexec/electron" "${lib.getLib vulkan-loader}/lib/libvulkan.so.1"
    '';

    __structuredAttrs = true;
    dontBuild = true;
    dontUnpack = true;
    # We don't want to wrap the contents of $out/libexec automatically
    dontWrapGApps = true;
    passthru.dist = finalAttrs.finalPackage + "/libexec/electron";
  };

  darwin = finalAttrs: {
    nativeBuildInputs = [
      makeWrapper
      unzip
    ];

    buildCommand = ''
      mkdir -p $out/Applications
      unzip $src
      mv Electron.app $out/Applications
      mkdir -p $out/bin
      makeWrapper $out/Applications/Electron.app/Contents/MacOS/Electron $out/bin/electron
    '';

    passthru.dist = finalAttrs.finalPackage + "/Applications";
  };
in
stdenv.mkDerivation (
  finalAttrs:
  lib.recursiveUpdate (common stdenv.hostPlatform) (
    (if stdenv.hostPlatform.isDarwin then darwin else linux) finalAttrs
  )
)
