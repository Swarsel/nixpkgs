{
  lib,
  fetchurl,
  appimageTools,
  electron,
  fetchzip,
  makeWrapper,
  stdenvNoCC,
}:
(stdenvNoCC.mkDerivation rec {
  pname = "revolt-desktop";
  version = "1.0.8";
  nativeBuildInputs = [ makeWrapper ];
  dontBuild = true;
  dontConfigure = true;

  meta = {
    description = "Open source user-first chat platform";
    homepage = "https://revolt.chat/";
    changelog = "https://github.com/revoltchat/desktop/releases/tag/v${version}";
    license = lib.licenses.agpl3Only;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      heyimnova
      magistau
    ];

    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "revolt-desktop";
  };
}).overrideAttrs
  (
    final: prev:
    let
      inherit (prev) version;
    in
    if stdenvNoCC.hostPlatform.isLinux then
      {
        src =
          {
            aarch64-linux = fetchurl {
              hash = "sha256-VQXyXaL4Ma3peO1duAlyFwkb1CRQ/4DNZhjiAnhms6I=";
              url = "https://github.com/revoltchat/desktop/releases/download/v${version}/Revolt-${version}-arm64.AppImage";
            };

            armv7l-linux = fetchurl {
              hash = "sha256-Qwya5tgHjMB8IJi0ueGmkzgQMQu+rlsDoWIVpl6Vj2w=";
              url = "https://github.com/revoltchat/desktop/releases/download/v${version}/Revolt-${version}-armv7l.AppImage";
            };

            x86_64-linux = fetchurl {
              hash = "sha256-L23Je5p7VmQpOLC+IfmQRk2CKKUm4rNBdsYLvqLTlRY=";
              url = "https://github.com/revoltchat/desktop/releases/download/v${version}/Revolt-${version}.AppImage";
            };
          }
          .${stdenvNoCC.hostPlatform.system}
            or (throw "Unsupported system: ${stdenvNoCC.hostPlatform.system}");

        installPhase = ''
          runHook preInstall

          mkdir -p $out/bin $out/share/{applications,revolt-desktop}

          cp -a ${final.appimageContents}/{locales,resources} $out/share/revolt-desktop
          cp -a ${final.appimageContents}/revolt-desktop.desktop $out/share/applications/revolt-desktop.desktop
          cp -a ${final.appimageContents}/usr/share/icons $out/share/icons

          substituteInPlace $out/share/applications/revolt-desktop.desktop \
            --replace-fail 'Exec=AppRun' 'Exec=revolt-desktop'

          runHook postInstall
        '';

        postFixup = ''
          makeWrapper ${electron}/bin/electron $out/bin/revolt-desktop \
            --add-flags $out/share/revolt-desktop/resources/app.asar \
            --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform=wayland --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}"
        '';

        appimageContents = appimageTools.extractType2 { inherit (final) src pname version; };
        dontUnpack = true;
      }
    else
      assert stdenvNoCC.hostPlatform.isDarwin;
      {
        src = fetchzip {
          url = "https://github.com/revoltchat/desktop/releases/download/v${version}/Revolt-${version}-universal-mac.zip";
          hash = "sha256-CpG1LLYYHa9ho4rotDwSS+wNIJ2z0kBPqu70xKEFg+k=";
          stripRoot = false;
        };

        installPhase = ''
          runHook preInstall

          mkdir -p "$out/Applications/" "$out/bin/"
          mv Revolt.app "$out/Applications/"
          makeWrapper "$out/Applications/Revolt.app/Contents/MacOS/Revolt" "$out/bin/revolt-desktop"

          runHook postInstall
        '';
      }
  )
