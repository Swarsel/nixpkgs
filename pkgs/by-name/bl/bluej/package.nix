{
  lib,
  stdenv,
  fetchurl,
  copyDesktopItems,
  glib,
  gsettings-desktop-schemas,
  gtk3,
  imagemagick,
  makeDesktopItem,
  nix-update-script,
  openjdk21,
  openjfx21,
  unzip,
  wrapGAppsHook3,
}:
let
  openjdk = openjdk21.override (
    {
      enableJavaFX = true;
    }
    // lib.optionalAttrs stdenv.hostPlatform.isLinux {
      openjfx_jdk = openjfx21.override { withWebKit = true; };
    }
  );
in
stdenv.mkDerivation (finalAttrs: {
  pname = "bluej";
  version = "5.5.0";

  src = fetchurl {
    url = "https://github.com/k-pet-group/BlueJ-Greenfoot/releases/download/BLUEJ-RELEASE-${finalAttrs.version}/BlueJ-generic-${finalAttrs.version}.jar";
    sha256 = "sha256-UClhTH/9oFfhjYsScBvmD4cKZUJwuAsiyRTiVkPAV0o=";
  };

  nativeBuildInputs = [
    wrapGAppsHook3
    copyDesktopItems
    imagemagick
    unzip
  ];

  buildInputs = [
    glib
    gtk3
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib

    cp -r ./lib $out/lib/bluej

    mkdir -p $out/share/icons/hicolor/{16x16,32x32,48x48,64x64,128x128,256x256}/apps

    for dimension in 16x16 32x32 48x48 64x64 128x128 256x256; do
      magick convert ./icons/bluej-icon-512-embossed.png -geometry $dimension\
        $out/share/icons/hicolor/$dimension/apps/bluej.png
    done

    makeWrapper ${openjdk}/bin/java $out/bin/bluej \
      "''${gappsWrapperArgs[@]}" \
      --suffix XDG_DATA_DIRS : ${gtk3}/share/gsettings-schemas/${gtk3.name}/ \
      --add-flags "-Dawt.useSystemAAFontSettings=on \
                   --add-opens javafx.graphics/com.sun.glass.ui=ALL-UNNAMED \
                   --add-opens javafx.graphics/com.sun.javafx.scene.input=ALL-UNNAMED \
                   -cp $out/lib/bluej/boot.jar bluej.Boot"

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Application"
        "Development"
      ];

      comment = "A simple powerful Java IDE";
      desktopName = "BlueJ";
      exec = "bluej";
      icon = "bluej";
      name = "BlueJ";
    })
  ];

  dontWrapGApps = true;
  sourceRoot = "dist";

  unpackPhase = ''
    runHook preUnpack

    unzip -d jar ${finalAttrs.src}
    unzip -d dist jar/bluej-dist.jar

    runHook postUnpack
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Simple integrated development environment for Java";
    homepage = "https://www.bluej.org/";

    license = with lib.licenses; [
      gpl2Plus
      classpathException20
    ];

    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];

    maintainers = with lib.maintainers; [
      weirdrock
      eveeifyeve # Darwin
    ];

    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "bluej";
  };

})
