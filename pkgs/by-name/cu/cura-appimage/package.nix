{
  lib,
  stdenv,
  fetchurl,
  appimageTools,
  copyDesktopItems,
  makeDesktopItem,
  nix-update-script,
  stdenvNoCC,
  wrapGAppsHook3,
  writeScriptBin,
}:

stdenvNoCC.mkDerivation rec {
  pname = "cura-appimage";
  version = "5.13.0";

  src = fetchurl {
    url = "https://github.com/Ultimaker/Cura/releases/download/${version}/Ultimaker-Cura-${version}-linux-X64.AppImage";
    hash = "sha256-EA8GgSeyWYFn8Auk2w4Gmd7UWt+Xu6stIv8XGh4ezEA=";
  };

  nativeBuildInputs = [
    copyDesktopItems
    wrapGAppsHook3
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp ${script}/bin/${wrapperScriptName} $out/bin/cura

    mkdir -p $out/share/applications $out/share/icons/hicolor/128x128/apps
    install -Dm644 ${appimageContents}/usr/share/icons/hicolor/128x128/apps/cura-icon.png $out/share/icons/hicolor/128x128/apps/cura-icon.png

    runHook postInstall
  '';

  # Give some good names so the intermediate packages are easy
  # to recognise by name in the Nix store.
  appimageBinName = "cura-appimage-tools-output";

  appimageContents = appimageTools.extract {
    inherit pname version src;
  };

  curaAppimageToolsWrapped = appimageTools.wrapType2 {
    inherit src;
    inherit version;
    # For `appimageTools.wrapType2`, `pname` determines the binary's name in `bin/`.
    pname = appimageBinName;
    extraPkgs = _: [ ];
  };

  desktopItems = [
    # Based on upstream.
    # https://github.com/Ultimaker/Cura/blob/382b98e8b0c910fdf8b1509557ae8afab38f1817/packaging/AppImage/cura.desktop.jinja
    (makeDesktopItem {
      categories = [ "Graphics" ];
      comment = meta.longDescription;
      desktopName = "UltiMaker Cura";
      exec = "cura";
      genericName = "3D Printing Software";
      icon = "cura-icon";

      keywords = [
        "3D"
        "Printing"
      ];

      mimeTypes = [
        "model/stl"
        "application/vnd.ms-3mfdocument"
        "application/prs.wavefront-obj"
        "image/bmp"
        "image/gif"
        "image/jpeg"
        "image/png"
        "text/x-gcode"
        "application/x-amf"
        "application/x-ply"
        "application/x-ctm"
        "model/vnd.collada+xml"
        "model/gltf-binary"
        "model/gltf+json"
        "model/vnd.collada+xml+zip"
      ];

      name = "cura";
      terminal = false;
      type = "Application";
    })
  ];

  dontUnpack = true;

  # The `QT_QPA_PLATFORM=xcb` fixes Wayland support, see https://github.com/NixOS/nixpkgs/issues/186570#issuecomment-2526277637
  # The `GTK_USE_PORTAL=1` fixes file dialog issues under Gnome, see https://github.com/NixOS/nixpkgs/pull/372614#issuecomment-2585663161
  script = writeScriptBin wrapperScriptName ''
    #!${stdenv.shell}
    # AppImage version of Cura loses current working directory and treats all paths relateive to $HOME.
    # So we convert each of the files passed as argument to an absolute path.
    # This fixes use cases like `cd /path/to/my/files; cura mymodel.stl anothermodel.stl`.

    args=()
    for a in "$@"; do
      if [ -e "$a" ]; then
        a="$(realpath "$a")"
      fi
      args+=("$a")
    done
    QT_QPA_PLATFORM=xcb GTK_USE_PORTAL=1 exec "${curaAppimageToolsWrapped}/bin/${appimageBinName}" "''${args[@]}"
  '';

  wrapperScriptName = "${pname}-wrapper-script";
  passthru.updateScript = nix-update-script { extraArgs = [ "--version-regex=([56789].+)" ]; };

  meta = {
    description = "3D printing software";

    longDescription = ''
      Cura converts 3D models into paths for a 3D printer. It prepares your print for maximum accuracy, minimum printing time and good reliability with many extra features that make your print come out great.
    '';

    homepage = "https://github.com/ultimaker/cura";
    changelog = "https://github.com/Ultimaker/Cura/releases/tag/${version}";
    license = lib.licenses.lgpl3Plus;

    maintainers = with lib.maintainers; [
      pbek
      nh2
      fliegendewurst
    ];

    platforms = [ "x86_64-linux" ];
    mainProgram = "cura";
  };
}
