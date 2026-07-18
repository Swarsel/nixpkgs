{
  lib,
  stdenv,
  autoPatchelfHook,
  cairo,
  copyDesktopItems,
  dbus,
  flac,
  glib,
  lame,
  libGL,
  libasyncns,
  libcap,
  libdrm,
  libgcc,
  libopus,
  libsndfile,
  libvorbis,
  libx11,
  libxau,
  libxcb,
  libxcursor,
  libxdmcp,
  libxext,
  libxfixes,
  libxi,
  libxinerama,
  libxrandr,
  libxrender,
  libxscrnsaver,
  makeDesktopItem,
  makeWrapper,
  megacmd,
  mpg123,
  pango,
  pulseaudio,
  runCommand,
  systemd,
  unzip,
  vulkan-loader,
  wayland,
  xorg_sys_opengl,
}:

let
  pname = "legends-of-equestria";
  version = "2025.06.002";
  description = "Free-to-play MMORPG";

  srcOptions = {
    aarch64-darwin = {
      outputHash = "PpDUFnobznB5FHYSF+m9S3RcNIdi7eWyxxDHRdS+zlY=";
      url = "https://mega.nz/file/xr4AHIrb#pD5wDIiYys2my4_59UWiYoqBpdyUQHf_CalPZe7hpME";
    };

    x86_64-linux = {
      outputHash = "IdcowkU2k2grg133jTf3EOENATCCige64BMYXtFupRE=";
      url = "https://mega.nz/file/QmBXXDiC#XoG19N2_uBIHVKDNId5mE4cod9q29iPkYOfGDgAX_Oo";
    };
  };

  runtimeDeps = [
    dbus.lib
    xorg_sys_opengl
    systemd
    libcap.lib
    libdrm
    pulseaudio
    libsndfile
    flac
    libvorbis
    mpg123
    lame.lib
    libGL
    vulkan-loader
    libasyncns
    libx11
    libxcb
    libxau
    libxdmcp
    libxext
    libxcursor
    libxrender
    libxfixes
    libxinerama
    libxi
    libxrandr
    libxscrnsaver
  ];
in
stdenv.mkDerivation {
  inherit pname version;

  src =
    runCommand "mega-loe"
      (
        srcOptions.${stdenv.hostPlatform.system}
        // {
          inherit version;

          nativeBuildInputs = [
            megacmd
            unzip
          ];

          outputHashAlgo = "sha256";
          outputHashMode = "recursive";
          pname = "${pname}-source";
        }
      )
      ''
        export HOME=$(mktemp -d)
        dest=$HOME/mega-loe
        mkdir -p $dest
        mega-get "$url" $dest
        mkdir -p $out
        unzip -d $out $dest/*.zip
      '';

  nativeBuildInputs = [
    makeWrapper
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    copyDesktopItems
    autoPatchelfHook
  ];

  buildInputs = [
    libgcc
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    cairo
    dbus
    glib
    pango
    wayland
  ];

  installPhase =
    if stdenv.hostPlatform.isLinux then
      ''
        runHook preInstall

        loeHome=$out/lib/${pname}
        mkdir -p $loeHome
        cp -r * $loeHome

        chmod +x $loeHome/LoE.x86_64
        makeWrapper $loeHome/LoE.x86_64 $out/bin/LoE \
          --suffix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeDeps}"

        icon=$out/share/icons/hicolor/128x128/apps/legends-of-equestria.png
        mkdir -p $(dirname $icon)
        ln -s $loeHome/LoE_Data/Resources/UnityPlayer.png $icon

        runHook postInstall
      ''
    else
      ''
        runHook preInstall

        mkdir -p $out/Applications
        cp -r *.app $out/Applications

        runHook postInstall
      '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Game" ];
      comment = description;
      desktopName = "Legends of Equestria";
      exec = "LoE";
      genericName = "Legends of Equestria";
      icon = "legends-of-equestria";
      name = "legends-of-equestria";
    })
  ];

  dontBuild = true;
  passthru.updateScript = ./update.sh;

  meta = {
    inherit description;
    homepage = "https://www.legendsofequestria.com";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ ulysseszhan ];
    platforms = lib.attrNames srcOptions;
    mainProgram = "LoE";
    downloadPage = "https://www.legendsofequestria.com/downloads";
  };

}
