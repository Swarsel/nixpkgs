{
  lib,
  stdenv,
  fetchurl,
  copyDesktopItems,
  fetchzip,
  makeDesktopItem,
  makeWrapper,
  wineWow64Packages,
  winetricks,
}:
let
  wine = wineWow64Packages.staging;
in
stdenv.mkDerivation rec {
  pname = "vtfedit";
  version = "1.3.3";

  src = fetchzip {
    url = "https://nemstools.github.io/files/vtfedit${lib.replaceStrings [ "." ] [ "" ] version}.zip";
    hash = "sha256-6a8YuxgYm7FB+2pFcZAMtE1db4hqpEk0z5gv2wHl9bI=";
    stripRoot = false;
  };

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/share/icons/hicolor/256x256/apps
    mkdir -p $out/share/lib
    mkdir -p $out/share/mime/packages

    substitute ${./vtfedit.bash} $out/bin/vtfedit \
      --replace-fail "@out@" "${placeholder "out"}" \
      --replace-fail "@path@" "${nativeRuntimeInputs}"
    chmod +x $out/bin/vtfedit

    cp ${icon} $out/share/icons/hicolor/256x256/apps/vtfedit.png
    cp -r ${if builtins.elem "i686-linux" wine.meta.platforms then "x86" else "x64"}/* $out/share/lib
    cp ${./mimetype.xml} $out/share/mime/packages/vtfedit.xml

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Graphics" ];
      comment = meta.description;
      desktopName = "VTFEdit";
      exec = "vtfedit %f";
      icon = "vtfedit";
      mimeTypes = [ "application/x-vtfedit" ];
      name = pname;
      terminal = false;
    })
  ];

  icon = fetchurl {
    hash = "sha256-Jpqo/s1wO2U5Z1DSZvADTfdH+8ycr0KF6otQbAE+jts=";
    url = "https://web.archive.org/web/20230906220249im_/https://valvedev.info/tools/vtfedit/thumb.png";
  };

  nativeRuntimeInputs = lib.makeBinPath [
    wine
    winetricks
  ];

  meta = {
    inherit (wine.meta) platforms;
    description = "VTF file viewer/editor";
    homepage = "https://nemstools.github.io/pages/VTFLib.html";
    license = lib.licenses.lgpl21Plus;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ ];
  };
}
