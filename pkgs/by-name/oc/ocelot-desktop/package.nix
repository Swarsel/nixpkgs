{
  lib,
  stdenv,
  fetchurl,
  # deps
  alsa-lib,
  copyDesktopItems,
  jre,
  libGL,
  libjack2,
  libpulseaudio,
  libx11,
  libxcursor,
  libxext,
  libxrandr,
  libxxf86vm,
  makeBinaryWrapper,
  makeDesktopItem,
  pipewire,
  # native
  unzip,
  # runtime (path)
  xrandr,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "ocelot-desktop";
  version = "1.14.2";

  # Cannot build from source because sbt/scala support is completely non-existent in nixpkgs
  src = fetchurl {
    url = "https://gitlab.com/api/v4/projects/9941848/packages/generic/ocelot-desktop/v${finalAttrs.version}/ocelot-desktop-v${finalAttrs.version}.jar";
    hash = "sha256-ZnXFCcm/b4hXLUrL7QZmRYwEFksKkIGI8zDqfXB+uhc=";
  };

  nativeBuildInputs = [
    makeBinaryWrapper
    copyDesktopItems
    unzip
  ];

  installPhase =
    let
      # does darwin need any deps?
      runtimeLibs = lib.optionals stdenv.hostPlatform.isLinux [
        # openal
        alsa-lib
        libjack2
        libpulseaudio
        pipewire

        # lwjgl
        libGL
        libx11
        libxcursor
        libxext
        libxrandr
        libxxf86vm
      ];
      runtimePrograms = lib.optionals stdenv.hostPlatform.isLinux [
        # https://github.com/LWJGL/lwjgl/issues/128
        xrandr
      ];
    in
    ''
      runHook preInstall

      mkdir -p $out/{bin,share/ocelot-desktop}
      install -Dm644 ${finalAttrs.src} $out/share/ocelot-desktop/ocelot-desktop.jar

      makeBinaryWrapper ${jre}/bin/java $out/bin/ocelot-desktop \
        --set JAVA_HOME ${jre.home} \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibs}" \
        --prefix PATH : "${lib.makeBinPath runtimePrograms}" \
        --add-flags "-jar $out/share/ocelot-desktop/ocelot-desktop.jar"

      # copy icons from zip file
      # ocelot/desktop/images/icon*.png
      # 16,32,64,128,256

      for size in 16 32 64 128 256; do
        mkdir -p $out/share/icons/hicolor/"$size"x"$size"/apps
        unzip -p $out/share/ocelot-desktop/ocelot-desktop.jar \
          ocelot/desktop/images/icon"$size".png > $out/share/icons/hicolor/"$size"x"$size"/apps/ocelot-desktop.png
      done

      runHook postInstall
    '';

  __darwinAllowLocalNetworking = true;

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Development"
        "Emulator"
      ];

      comment = "An advanced OpenComputers emulator";
      desktopName = "Ocelot Desktop";
      exec = "ocelot-desktop -w %f";
      genericName = "OpenComputers Emulator";
      icon = "ocelot-desktop";

      keywords = [
        "Ocelot"
        "OpenComputers"
        "Emulator"
        "oc"
        "lua"
        "OpenOS"
        "ocemu"
        "mc"
        "Minecraft"
      ];

      mimeTypes = [
        "inode/directory"
      ];

      name = "ocelot-desktop";
      startupNotify = true;
      startupWMClass = "Ocelot Desktop"; # (maybe broken)
      terminal = false;
      tryExec = "ocelot-desktop";
    })
  ];

  dontBuild = true;
  dontConfigure = true;
  dontUnpack = true;
  preferLocal = true;

  meta = {
    description = "Advanced OpenComputers emulator";
    homepage = "https://ocelot.fomalhaut.me/desktop";
    changelog = "https://gitlab.com/cc-ru/ocelot/ocelot-desktop/-/releases/v${finalAttrs.version}";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = with lib.maintainers; [ griffi-gh ];
    platforms = with lib.platforms; linux ++ darwin;

    badPlatforms = [
      # missing compatible lwjgl.dylib
      "aarch64-darwin"
    ];

    mainProgram = "ocelot-desktop";
  };
})
