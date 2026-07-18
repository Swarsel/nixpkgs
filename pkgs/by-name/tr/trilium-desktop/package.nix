{
  lib,
  stdenv,
  fetchurl,
  asar,
  autoPatchelfHook,
  copyDesktopItems,
  # use specific electron since it has to load a compiled module
  electron_41,
  makeBinaryWrapper,
  makeDesktopItem,
  unzip,
  wrapGAppsHook3,
}:

let
  pname = "trilium-desktop";
  version = "0.103.0";

  triliumSource = os: arch: hash: {
    inherit hash;
    url = "https://github.com/TriliumNext/Trilium/releases/download/v${version}/TriliumNotes-v${version}-${os}-${arch}.zip";
  };

  linuxSource = triliumSource "linux";
  darwinSource = triliumSource "macos";

  # exposed like this for update.sh
  x86_64-linux.hash = "sha256-1d6nYhj83LWzglkWoOtAj6lNPkik1qXY5lVpr1iG7No=";
  aarch64-linux.hash = "sha256-LQMNgj1Ml8gShlPS0qgD/a+Fw4SjvvHrw6XAcSLN7q4=";
  aarch64-darwin.hash = "sha256-dMlgJgDuxZH1jnvLalmgDUMVCdWQ8AviGt86aeMbGVY=";

  sources = {
    aarch64-darwin = darwinSource "arm64" aarch64-darwin.hash;
    aarch64-linux = linuxSource "arm64" aarch64-linux.hash;
    x86_64-linux = linuxSource "x64" x86_64-linux.hash;
  };

  src = fetchurl sources.${stdenv.hostPlatform.system};

  meta = {
    description = "Hierarchical note taking application with focus on building large personal knowledge bases";
    homepage = "https://triliumnotes.org/";
    license = lib.licenses.agpl3Plus;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      eliandoran
      fliegendewurst
    ];

    platforms = lib.attrNames sources;
    mainProgram = "trilium";
  };

  linux = stdenv.mkDerivation {
    inherit
      pname
      version
      meta
      src
      ;

    # Remove trilium-portable.sh, so trilium knows it is packaged making it stop auto generating a desktop item on launch
    postPatch = ''
      rm ./trilium-portable.sh
    '';

    nativeBuildInputs = [
      unzip
      makeBinaryWrapper
      wrapGAppsHook3
      copyDesktopItems
      autoPatchelfHook
      asar
    ];

    buildInputs = [
      (lib.getLib stdenv.cc.cc)
    ];

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/bin"
      mkdir -p "$out/share/trilium"
      mkdir -p "$out/share/icons/hicolor/512x512/apps"

      cp -r ./* "$out/share/trilium/"
      rm $out/share/trilium/{*.so*,trilium,chrome_crashpad_handler,chrome-sandbox}

      # Rebuild the ASAR archive to patchelf native module.
      tmp=$(mktemp -d)
      asar extract $out/share/trilium/resources/app.asar $tmp
      rm $out/share/trilium/resources/app.asar

      autoPatchelf $tmp
      cp $tmp/public/assets/icon.png $out/share/icons/hicolor/512x512/apps/trilium.png

      asar pack $tmp/ $out/share/trilium/resources/app.asar
      rm -rf $tmp

      makeWrapper ${lib.getExe electron_41} $out/bin/trilium \
        "''${gappsWrapperArgs[@]}" \
        --set-default ELECTRON_IS_DEV 0 \
        --add-flags $out/share/trilium/resources/app.asar

      runHook postInstall
    '';

    desktopItems = [
      (makeDesktopItem {
        categories = [ "Office" ];
        comment = meta.description;
        desktopName = "Trilium Notes";
        exec = "trilium";
        icon = "trilium";
        name = "Trilium";
        startupWMClass = "Trilium Notes";
      })
    ];

    dontWrapGApps = true;
    passthru.updateScript = ./update.sh;
  };

  darwin = stdenv.mkDerivation {
    inherit
      pname
      version
      meta
      src
      ;

    nativeBuildInputs = [
      unzip
    ];

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/Applications/Trilium Notes.app"
      cp -r * "$out/Applications/Trilium Notes.app/"
      runHook postInstall
    '';
  };

in
if stdenv.hostPlatform.isDarwin then darwin else linux
