{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  copyDesktopItems,
  cups,
  fetchzip,
  makeDesktopItem,
  makeWrapper,
  qt6,
  undmg,
  writeScript,
  xkeyboard-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "010editor";
  version = "16.0.4";
  src = finalAttrs.passthru.srcs.${stdenv.hostPlatform.system};
  strictDeps = true;

  nativeBuildInputs =
    lib.optionals stdenv.hostPlatform.isLinux [
      autoPatchelfHook
      copyDesktopItems
      makeWrapper
      qt6.wrapQtAppsHook
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [ undmg ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    cups
    qt6.qtbase
    qt6.qtwayland
    xkeyboard-config
  ];

  installPhase =
    let
      darwinInstall = ''
        mkdir -p $out/Applications
        cp -R *.app $out/Applications
      '';

      linuxInstall = ''
        mkdir -p $out/opt && cp -ar source/* $out/opt

        # Wrap binary: clean env, fix XKB lookup
        makeWrapper $out/opt/010editor $out/bin/010editor \
          --unset QT_PLUGIN_PATH \
          --set XKB_CONFIG_ROOT ${xkeyboard-config}/share/X11/xkb

        # Install icon
        install -D $out/opt/010_icon_128x128.png $out/share/icons/hicolor/128x128/apps/010.png
      '';
    in
    ''
      runHook preInstall
      ${if stdenv.hostPlatform.isDarwin then darwinInstall else linuxInstall}
      runHook postInstall
    '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Development" ];
      desktopName = "010 Editor";
      exec = "010editor %f";
      genericName = "Text and hex editor";
      icon = "010";

      mimeTypes = [
        "text/html"
        "text/plain"
        "text/x-c++hdr"
        "text/x-c++src"
        "text/xml"
      ];

      name = "010editor";
    })
  ];

  dontBuild = true;
  dontConfigure = true;
  sourceRoot = ".";

  passthru = {
    updateScript = writeScript "update-010editor" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p curl pcre2 common-updater-scripts

      set -eu -o pipefail

      # Expect the text in format of "Version: major.minor.patchlevel
      newVersion="$(curl -s https://sweetscape.com/download/010editor/ | pcre2grep -o1 'Version: ([0-9]+\.[0-9]+\.[0-9]+)' | sort -u)"
      for platform in ${toString finalAttrs.meta.platforms}; do
        update-source-version _010editor "$newVersion" --source-key=passthru.srcs.$platform --ignore-same-version
      done
    '';
  };

  passthru.srcs = {
    aarch64-darwin = fetchurl {
      hash = "sha256-+yU5JdPNS2BfiZLsBLyyC+ieVNqbIWba3teBlTIDWtk=";
      url = "https://download.sweetscape.com/010EditorMacARM64Installer${finalAttrs.version}.dmg";
    };

    x86_64-linux = fetchzip {
      hash = "sha256-M1D2Bmi45sYiB0Ci+0X0AxyIeR+On60xt4jP1Jsy5tA=";
      url = "https://download.sweetscape.com/010EditorLinux64Installer${finalAttrs.version}.tar.gz";
    };
  };

  meta = {
    description = "Text and hex editor";
    homepage = "https://www.sweetscape.com/010editor/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ eljamm ];

    platforms = [
      "aarch64-darwin"
      "x86_64-linux"
    ];

    mainProgram = "010editor";
  };
})
