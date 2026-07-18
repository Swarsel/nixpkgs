{
  lib,
  fetchurl,
  appimageTools,
  imagemagick,
  makeDesktopItem,
  runCommand,
}:

let
  icon =
    runCommand "xnconvert-icon.png"
      {
        src = fetchurl {
          url = "https://www.xnview.com/img/app-xnconvert-512.webp";
          hash = "sha256-le+rvthQndY3KbkPYuMGZDDcvdpvH9CIS2REP1vmDXg=";
        };

        nativeBuildInputs = [ imagemagick ];
      }
      ''
        convert $src $out
      '';
  desktopItem = (
    makeDesktopItem {
      categories = [ "Graphics" ];
      comment = "A fast, powerful and free cross-platform batch image converter.";
      desktopName = "XnConvert";
      exec = "xnconvert";
      icon = "xnconvert";
      name = "xnconvert";
    }
  );
  version = "1.105.0";
in
appimageTools.wrapType2 {
  inherit version;
  pname = "xnconvert";

  src = fetchurl {
    url = "https://download.xnview.com/old_versions/XnConvert/XnConvert-${version}.glibc2.17-x86_64.AppImage";
    hash = "sha256-eWQSUVxR3G3XbwBCht6LW3t3/N668jH4UqK5OnRY0ko=";
  };

  extraInstallCommands = ''
    install -m 444 -D ${icon} $out/share/icons/hicolor/512x512/apps/xnconvert.png

    mkdir -p $out/share/applications/
    cp ${desktopItem}/share/applications/*.desktop $out/share/applications/
  '';

  extraPkgs = pkgs: [
    pkgs.qt5.qtbase
  ];

  meta = {
    description = "Fast, powerful and free cross-platform batch image converter";

    longDescription = ''
      XnConvert is a fast, powerful and free cross-platform batch image converter.
      It allows to automate editing of your photo collections: you can rotate,
      convert and compress your images, photos and pictures easily, and apply over
      80 actions (like resize, crop, color adjustments, filter, ...).
      All common picture and graphics formats are supported (JPEG, TIFF, PNG, GIF,
      WebP, PSD, JPEG2000, JPEG-XL, OpenEXR, camera RAW, HEIC, PDF, DNG, CR2).
      You can save and re-use your presets for another batch image conversion.
    '';

    homepage = "https://www.xnview.com/en/xnconvert";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ aldenparker ];
    platforms = lib.platforms.linux;
    mainProgram = "xnconvert";
  };
}
