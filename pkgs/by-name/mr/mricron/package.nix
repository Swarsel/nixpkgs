{
  lib,
  stdenv,
  fetchurl,
  atk,
  autoPatchelfHook,
  cairo,
  copyDesktopItems,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk2,
  libx11,
  makeDesktopItem,
  makeWrapper,
  pango,
  unzip,
  zlib,
}:
stdenv.mkDerivation (finalAttrs: {

  pname = "mricron";
  version = "1.0.20190902";

  src = fetchurl {
    url = "https://github.com/neurolabusc/MRIcron/releases/download/v${finalAttrs.version}/MRIcron_linux.zip";
    hash = "sha256-C155u9dvYEyWRfTv3KNQFI6aMWIAjgvdSIqMuYVIOQA=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    makeWrapper
    unzip
  ];

  buildInputs = [
    atk
    cairo
    freetype
    fontconfig
    gtk2
    glib
    gdk-pixbuf
    pango
    libx11
    zlib
  ];

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/icons/hicolor/256x256/apps

    install -Dm777 ./MRIcron $out/bin/mricron
    install -Dm444 -t $out/share/icons/hicolor/scalable/apps/ ./Resources/mricron.svg
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Graphics"
        "MedicalSoftware"
        "Science"
      ];

      comment = "Application to display NIfTI medical imaging data";
      desktopName = "MRIcron";
      exec = "mricron %U";
      icon = "mricron";

      keywords = [
        "medical"
        "imaging"
        "nifti"
      ];

      name = "mricron";
      terminal = false;
      type = "Application";
    })
  ];

  meta = {
    description = "Application to display NIfTI medical imaging data";
    homepage = "https://people.cas.sc.edu/rorden/mricron/index.HTML";
    license = lib.licenses.bsd1;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ adriangl ];
    platforms = lib.platforms.linux;
    mainProgram = "mricron";
  };
})
