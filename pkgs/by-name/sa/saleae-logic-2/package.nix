{
  lib,
  fetchurl,
  appimageTools,
  makeDesktopItem,
}:
let
  pname = "saleae-logic-2";
  version = "2.4.44";
  src = fetchurl {
    url = "https://downloads2.saleae.com/logic2/Logic-${version}-linux-x64.AppImage";
    hash = "sha256-lJp0al4tRqXwb6I8iziCav481XNAuEjASo1ZfUWdYLU=";
  };
  desktopItem = makeDesktopItem {
    categories = [ "Development" ];
    comment = "Software for Saleae logic analyzers";
    desktopName = "Saleae Logic";
    exec = "saleae-logic-2";
    genericName = "Logic analyzer";
    icon = "Logic";
    name = "saleae-logic-2";
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands =
    let
      appimageContents = appimageTools.extractType2 { inherit pname version src; };
    in
    ''
      mkdir -p $out/etc/udev/rules.d
      cp ${appimageContents}/resources/linux-x64/99-SaleaeLogic.rules $out/etc/udev/rules.d/
      mkdir $out/share
      ln -s ${desktopItem}/share/applications $out/share/
      for size in 16 32 48 64 128 256; do
        install -Dm644 -t $out/share/icons/hicolor/"$size"x"$size"/apps \
          ${appimageContents}/usr/share/icons/hicolor/"$size"x"$size"/apps/Logic.png
      done
    '';

  extraPkgs =
    pkgs: with pkgs; [
      wget
      unzip
      glib
      libx11
      libxcb
      libxcomposite
      libxcursor
      libxdamage
      libxext
      libxfixes
      libxi
      libxrender
      libxtst
      nss
      nspr
      dbus
      gdk-pixbuf
      gtk3
      pango
      atk
      cairo
      expat
      libxrandr
      libxscrnsaver
      alsa-lib
      at-spi2-core
      cups
      libxcrypt-legacy
    ];

  meta = {
    description = "Software for Saleae logic analyzers";
    homepage = "https://www.saleae.com/";
    changelog = "https://ideas.saleae.com/f/changelog/";
    license = lib.licenses.unfree;

    maintainers = with lib.maintainers; [
      j-hui
      newam
    ];

    platforms = [ "x86_64-linux" ];
  };
}
