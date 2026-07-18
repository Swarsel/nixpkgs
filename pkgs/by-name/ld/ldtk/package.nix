{
  lib,
  stdenv,
  fetchurl,
  appimage-run,
  copyDesktopItems,
  makeDesktopItem,
  makeWrapper,
  nix-update-script,
  unzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ldtk";
  version = "1.5.3";

  src = fetchurl {
    url = "https://github.com/deepnight/ldtk/releases/download/v${finalAttrs.version}/ubuntu-distribution.zip";
    hash = "sha256-i7HIcKs10srfvwihGdMEnnmGoqgFWNJhC6vGf81QJWY=";
  };

  nativeBuildInputs = [
    unzip
    makeWrapper
    copyDesktopItems
    appimage-run
  ];

  buildInputs = [ appimage-run ];

  installPhase = ''
    runHook preInstall

    install -Dm644 'LDtk ${finalAttrs.version} installer.AppImage' $out/share/ldtk.AppImage
    makeWrapper ${appimage-run}/bin/appimage-run $out/bin/ldtk \
      --add-flags $out/share/ldtk.AppImage
    install -Dm644 src/ldtk.png $out/share/icons/hicolor/512x512/apps/ldtk.png

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Utility" ];
      comment = "2D level editor";
      desktopName = "LDtk";
      exec = "ldtk";
      icon = "ldtk";
      mimeTypes = [ "application/json" ];
      name = "ldtk";
      terminal = false;
    })
  ];

  unpackPhase = ''
    runHook preUnpack

    unzip $src
    appimage-run -x src 'LDtk ${finalAttrs.version} installer.AppImage'

    runHook postUnpack
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Modern, lightweight and efficient 2D level editor";
    homepage = "https://ldtk.io/";
    changelog = "https://github.com/deepnight/ldtk/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = with lib.maintainers; [ felschr ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "ldtk";
  };
})
