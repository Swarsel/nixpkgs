{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  atkmm,
  buildFHSEnv,
  bzip2,
  cairo,
  cups,
  dbus,
  dpkg,
  expat,
  ffmpeg,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk3,
  krb5,
  libGL,
  libdrm,
  libexif,
  libgbm,
  libice,
  libnotify,
  libsm,
  libuuid,
  libva,
  libx11,
  libxcb,
  libxcb-image,
  libxcb-keysyms,
  libxcb-render-util,
  libxcb-wm,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxext,
  libxfixes,
  libxft,
  libxi,
  libxkbcommon,
  libxml2,
  libxrandr,
  libxrender,
  libxscrnsaver,
  libxshmfence,
  libxt,
  libxtst,
  nspr,
  nss,
  pango,
  pulseaudio,
  qt6,
  stdenvNoCC,
  systemd,
  vulkan-loader,
  wayland,
  writeShellScript,
  zlib,
}:
let
  wechat-uos-env = stdenvNoCC.mkDerivation {
    buildCommand = ''
      mkdir -p $out/etc
      mkdir -p $out/usr/bin
      mkdir -p $out/usr/share
      mkdir -p $out/opt
      mkdir -p $out/var

      ln -s ${wechat}/opt/* $out/opt/
    '';

    name = "wechat-uos-env";
    preferLocalBuild = true;
    meta.priority = 1;
  };

  wechat-uos-runtime = [
    stdenv.cc.cc
    stdenv.cc.libc
    pango
    zlib
    libxcb-wm
    libxcb-image
    libxcb-keysyms
    libxcb-render-util
    libx11
    libxt
    libxext
    libsm
    libice
    libxcb
    libxkbcommon
    libxshmfence
    libxi
    libxft
    libxcursor
    libxfixes
    libxscrnsaver
    libxcomposite
    libxdamage
    libxtst
    libxrandr
    libnotify
    atk
    atkmm
    cairo
    at-spi2-atk
    at-spi2-core
    alsa-lib
    dbus
    cups
    gtk3
    gdk-pixbuf
    libexif
    ffmpeg
    libva
    freetype
    fontconfig
    libxrender
    libuuid
    expat
    glib
    nss
    nspr
    libGL
    libxml2
    pango
    libdrm
    libgbm
    vulkan-loader
    systemd
    wayland
    pulseaudio
    qt6.qt5compat
    bzip2
    krb5
  ];

  wechat =
    let
      sources = import ./sources.nix;

      pname = "wechat-uos";
      version = sources.version;
      src = fetchurl (
        {
          curlOpts = "-A apt";
        }
        // (sources.${stdenv.hostPlatform.system}
          or (throw "Unsupported system: ${stdenv.hostPlatform.system}")
        )
      );
    in
    stdenvNoCC.mkDerivation {
      inherit pname src version;
      nativeBuildInputs = [ dpkg ];

      # Use ln for license to prevent being garbage collection
      installPhase = ''
        runHook preInstall
        mkdir -p $out

        cp -r wechat-uos/* $out

        runHook postInstall
      '';

      unpackPhase = ''
        runHook preUnpack

        dpkg -x $src ./wechat-uos

        runHook postUnpack
      '';

      meta = {
        description = "Messaging app";
        homepage = "https://weixin.qq.com/";
        license = lib.licenses.unfree;
        sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

        maintainers = with lib.maintainers; [
          pokon548
          xddxdd
        ];

        platforms = [
          "x86_64-linux"
          "aarch64-linux"
          "loongarch64-linux"
        ];

        mainProgram = "wechat-uos";
      };
    };
in
buildFHSEnv {
  inherit (wechat) pname version meta;

  extraInstallCommands = ''
    mkdir -p $out/share/applications
    mkdir -p $out/share/icons
    cp -r ${wechat.outPath}/opt/apps/com.tencent.wechat/entries/applications/com.tencent.wechat.desktop $out/share/applications
    cp -r ${wechat.outPath}/opt/apps/com.tencent.wechat/entries/icons/* $out/share/icons/

    substituteInPlace $out/share/applications/com.tencent.wechat.desktop \
      --replace-quiet 'Exec=/usr/bin/wechat' "Exec=$out/bin/wechat-uos --"

    # See https://github.com/NixOS/nixpkgs/issues/413491
    sed -i \
      -e '/\[Desktop Entry\]/a\' \
      -e 'StartupWMClass=wechat' \
      $out/share/applications/com.tencent.wechat.desktop
  '';

  extraOutputsToInstall = [
    "usr"
    "var/lib/uos"
    "var/uos"
    "etc"
  ];

  runScript = writeShellScript "wechat-uos-launcher" ''
    export QT_QPA_PLATFORM=xcb
    export QT_AUTO_SCREEN_SCALE_FACTOR=1
    export LD_LIBRARY_PATH=${lib.makeLibraryPath wechat-uos-runtime}

    if [[ ''${XMODIFIERS} =~ fcitx ]]; then
      export QT_IM_MODULE=fcitx
      export GTK_IM_MODULE=fcitx
    elif [[ ''${XMODIFIERS} =~ ibus ]]; then
      export QT_IM_MODULE=ibus
      export GTK_IM_MODULE=ibus
      export IBUS_USE_PORTAL=1
    fi

    ${wechat.outPath}/opt/apps/com.tencent.wechat/files/wechat
  '';

  targetPkgs = pkgs: [ wechat-uos-env ];
  passthru.updateScript = ./update.sh;
}
