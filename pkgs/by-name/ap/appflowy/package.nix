{
  lib,
  alsa-lib,
  autoPatchelfHook,
  copyDesktopItems,
  fetchzip,
  gst_all_1,
  gtk3,
  keybinder3,
  lcms2,
  libarchive,
  libgbm,
  libnotify,
  libpulseaudio,
  libva,
  libvdpau,
  libxscrnsaver,
  libxv,
  makeDesktopItem,
  makeWrapper,
  stdenvNoCC,
  xdg-user-dirs,
}:

let
  dist =
    {
      aarch64-darwin = {
        hash = "sha256-LSNvFL1ud/FkzNSGk17ZqN2debnqsjlVDHd4NBjTds0=";
        urlSuffix = "macos-universal.zip";
      };

      x86_64-linux = {
        hash = "sha256-A8JUYzEMQH1sEKYrKZ84QZAgYbz0OvpHa3t9RIUVE9c=";
        urlSuffix = "linux-x86_64.tar.gz";
      };
    }
    ."${stdenvNoCC.hostPlatform.system}"
      or (throw "appflowy: No source for system: ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "appflowy";
  version = "0.11.9";

  src = fetchzip {
    inherit (dist) hash;
    url = "https://github.com/AppFlowy-IO/appflowy/releases/download/${finalAttrs.version}/AppFlowy-${finalAttrs.version}-${dist.urlSuffix}";
    stripRoot = false;
  };

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
  ]
  ++ lib.optionals stdenvNoCC.hostPlatform.isLinux [ autoPatchelfHook ];

  buildInputs = lib.optionals stdenvNoCC.hostPlatform.isLinux [
    gtk3
    keybinder3
    libnotify
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    libva
    libvdpau
    lcms2
    libarchive
    alsa-lib
    libpulseaudio
    libgbm
    libxscrnsaver
    libxv
  ];

  installPhase =
    lib.optionalString stdenvNoCC.hostPlatform.isLinux ''
      runHook preInstall

      cd AppFlowy/

      mkdir -p $out/{bin,opt}

      # Copy archive contents to the outpout directory
      cp -r ./* $out/opt/

      # Copy icon
      install -Dm444 data/flutter_assets/assets/images/flowy_logo.svg $out/share/icons/hicolor/scalable/apps/appflowy.svg

      runHook postInstall
    ''
    + lib.optionalString stdenvNoCC.hostPlatform.isDarwin ''
      runHook preInstall

      mkdir -p $out/{Applications,bin}
      cp -r ./AppFlowy.app $out/Applications/

      runHook postInstall
    '';

  preFixup =
    lib.optionalString stdenvNoCC.hostPlatform.isLinux ''
      # Add missing libraries to appflowy using the ones it comes with
      makeWrapper $out/opt/AppFlowy $out/bin/appflowy \
        --set LD_LIBRARY_PATH "$out/opt/lib/" \
        --prefix PATH : "${lib.makeBinPath [ xdg-user-dirs ]}"
    ''
    + lib.optionalString stdenvNoCC.hostPlatform.isDarwin ''
      makeWrapper $out/Applications/AppFlowy.app/Contents/MacOS/AppFlowy $out/bin/appflowy
    '';

  desktopItems = lib.optionals stdenvNoCC.hostPlatform.isLinux [
    (makeDesktopItem {
      categories = [ "Office" ];
      comment = finalAttrs.meta.description;
      desktopName = "AppFlowy";
      exec = "appflowy %U";
      icon = "appflowy";
      mimeTypes = [ "x-scheme-handler/appflowy-flutter" ];
      name = "appflowy";
    })
  ];

  dontBuild = true;
  dontConfigure = true;

  meta = {
    description = "Open-source alternative to Notion";
    homepage = "https://www.appflowy.io/";
    changelog = "https://github.com/AppFlowy-IO/appflowy/releases/tag/${finalAttrs.version}";

    license = with lib.licenses; [
      # The LICENSE file clearly claims the project is using AGPL-3.0
      #
      # c.f. https://github.com/AppFlowy-IO/AppFlowy/blob/main/LICENSE
      agpl3Only
      # But, the source code has not been synced with any major release since
      # the end of 2025. One of the core team member said that they will "merge
      # Flutter code back into this public repository at a later stage". However,
      # 2 months later, nothing has changed.
      #
      # c.f. https://github.com/AppFlowy-IO/AppFlowy/issues/8479#issuecomment-4053301446
      unfreeRedistributable
    ];

    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ darkonion0 ];
    platforms = [ "x86_64-linux" ] ++ lib.platforms.darwin;
    mainProgram = "appflowy";
  };
})
