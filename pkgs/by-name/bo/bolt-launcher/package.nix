{
  lib,
  stdenv,
  buildFHSEnv,
  cairo,
  cef-binary,
  cmake,
  copyDesktopItems,
  fetchFromCodeberg,
  glib,
  jdk17,
  libarchive,
  libgbm,
  libnotify,
  libsm,
  libx11,
  libxcb,
  libxext,
  libxi,
  libxxf86vm,
  libz,
  luajit,
  makeDesktopItem,
  makeWrapper,
  ninja,
  pango,
  pkg-config,
  enableRS3 ? false,
}:
let
  cef = cef-binary.override {
    version = "141.0.7";
    chromiumVersion = "141.0.7390.108";
    gitRevision = "a5714cc";

    srcHashes = {
      aarch64-linux = "sha256-2A0hVzUVMBemhjnFE/CrKs4CU96Qkxy8S/SieaEJjwE=";
      x86_64-linux = "sha256-tZzUxeXxbYP8YfIQLbiSyihPcjZM9cd2Ad8gGCSvdGk=";
    };
  };
in
let
  bolt = stdenv.mkDerivation (finalAttrs: {
    pname = "bolt-launcher";
    version = "0.22.0";

    src = fetchFromCodeberg {
      owner = "AdamCake";
      repo = "Bolt";
      tag = finalAttrs.version;
      hash = "sha256-ncmyDav2CmsdDE/nCRmpWuBqutX72vD5/zNO1nvJIlE=";
      fetchSubmodules = true;
    };

    nativeBuildInputs = [
      cmake
      ninja
      luajit
      makeWrapper
      copyDesktopItems
      pkg-config
    ];

    buildInputs = [
      libgbm
      libx11
      libxcb
      libarchive
      libz
      cef
      jdk17
    ];

    cmakeFlags = [
      "-G Ninja"
    ]
    ++ lib.optionals (stdenv.hostPlatform.isAarch64) [
      (lib.cmakeFeature "PROJECT_ARCH" "arm64")
    ];

    preConfigure = ''
      mkdir -p cef
      ln -s ${cef} cef/dist
    '';

    postFixup = ''
      makeWrapper "$out/opt/bolt-launcher/bolt" "$out/bin/${finalAttrs.pname}-${finalAttrs.version}" \
      --set JAVA_HOME ${jdk17}
      mkdir -p $out/lib
      cp $out/usr/local/lib/libbolt-plugin.so $out/lib
      mkdir -p $out/share/icons/hicolor/256x256/apps
      cp ../icon/256.png $out/share/icons/hicolor/256x256/apps/${finalAttrs.pname}.png
    '';

    desktopItems = [
      (makeDesktopItem {
        categories = [ "Game" ];
        comment = "An alternative launcher for RuneScape";
        desktopName = "Bolt Launcher";
        exec = "bolt-launcher";
        genericName = finalAttrs.pname;
        icon = "bolt-launcher";
        name = "Bolt";
        startupWMClass = "BoltLauncher";
        terminal = false;
        type = "Application";
      })
    ];
  });
in
buildFHSEnv {
  inherit (bolt) pname version;

  extraInstallCommands = ''
    mkdir -p $out/share/applications
    mkdir -p $out/share/icons/hicolor/256x256/apps

    ln -s ${bolt}/share/applications/*.desktop $out/share/applications/

    ln -s ${bolt}/share/icons/hicolor/256x256/apps/*.png $out/share/icons/hicolor/256x256/apps/
  '';

  runScript = "${bolt.name}";

  targetPkgs =
    pkgs:
    [ bolt ]
    ++ (with pkgs; [
      libsm
      libxxf86vm
      libx11
      libxi
      libxext
      glib
      pango
      cairo
      gdk-pixbuf
      libz
      libcap
      libsecret
      SDL2
      sdl3
      libGL
      libnotify
    ])
    ++ lib.optionals enableRS3 (
      with pkgs;
      [
        gtk2-x11
        openssl_1_1
      ]
    );

  meta = {
    description = "Alternative launcher for RuneScape";

    longDescription = ''
      Bolt Launcher supports HDOS/RuneLite by default with an optional feature flag for RS3 (enableRS3).
    '';

    homepage = "https://codeberg.org/Adamcake/Bolt";
    changelog = "https://codeberg.org/Adamcake/Bolt/releases/tag/${bolt.version}";
    license = lib.licenses.agpl3Plus;

    maintainers = with lib.maintainers; [
      nezia
      jaspersurmont
      iedame
    ];

    platforms = lib.platforms.linux;
    mainProgram = "bolt-launcher";
  };
}
