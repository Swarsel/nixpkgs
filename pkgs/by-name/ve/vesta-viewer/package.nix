{
  lib,
  fetchurl,
  _7zz,
  autoPatchelfHook,
  copyDesktopItems,
  fetchzip,
  glib,
  gtk2,
  gtk3,
  libGL,
  libGLU,
  libgcc,
  libxtst,
  libxxf86vm,
  makeDesktopItem,
  stdenvNoCC,
  temurin-jre-bin,
}:

let
  pname = "vesta-viewer";
  version = "3.5.8";
  meta = {
    description = "3D visualization program for structural models, volumetric data such as electron/nuclear densities, and crystal morphologies";
    homepage = "https://jp-minerals.org/vesta/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ ulysseszhan ];

    platforms = [
      "x86_64-linux"
    ];

    mainProgram = "VESTA";
    downloadPage = "https://jp-minerals.org/vesta/en/download.html";
  };

  linuxArgs = {
    src = fetchzip {
      url = "https://jp-minerals.org/vesta/archives/${version}/VESTA-gtk3.tar.bz2";
      hash = "sha256-Dm4exMUgNZ6Sh8dVhsvLZGS38UXxe9t+9s3ttBQajGg=";
    };

    nativeBuildInputs = [
      copyDesktopItems
      autoPatchelfHook
    ];

    buildInputs = [
      glib
      libGL
      libGLU
      libgcc
      gtk3
      gtk2
      temurin-jre-bin
      libxxf86vm
      libxtst
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib/VESTA
      cp -r * $out/lib/VESTA

      mkdir -p $out/bin
      ln -s $out/lib/VESTA/VESTA{,-core,-gui} -t $out/bin

      mkdir -p $out/share/icons/hicolor/{128x128,256x256}/apps
      ln -s $out/lib/VESTA/img/logo.png $out/share/icons/hicolor/128x128/apps/VESTA.png
      ln -s $out/lib/VESTA/img/logo@2x.png $out/share/icons/hicolor/256x256/apps/VESTA.png

      runHook postInstall
    '';

    desktopItems = [
      (makeDesktopItem {
        categories = [ "Science" ];
        comment = meta.description;
        desktopName = "VESTA";
        exec = "VESTA %u";
        genericName = "VESTA";
        icon = "VESTA";
        mimeTypes = [ "application/x-vesta" ];
        name = "vesta";
      })
    ];
  };

  darwinArgs = {
    src = fetchurl {
      url = "https://jp-minerals.org/vesta/archives/${version}/VESTA.dmg";
      hash = "sha256-L8vj3MNwHo3m5wP1lByNjHZ4VTVOWSm0Aiw1ItosbSw=";
    };

    nativeBuildInputs = [
      _7zz # instead of undmg because of APFS
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/Applications
      cp -r *.app $out/Applications

      runHook postInstall
    '';

    sourceRoot = "VESTA/VESTA";
  };
in
stdenvNoCC.mkDerivation (
  {
    inherit pname version meta;
    # I could've written an update script here,
    # but I didn't bother because the stable version hasn't been updated for years.
  }
  // {
    "x86_64-linux" = linuxArgs;
  }
  .${stdenvNoCC.hostPlatform.system} or { }
)
