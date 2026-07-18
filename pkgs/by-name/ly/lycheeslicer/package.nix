{
  lib,
  fetchurl,
  appimageTools,
  libxshmfence,
  makeDesktopItem,
  wayland,
  wayland-protocols,
}:
let
  pname = "lycheeslicer";
  version = "7.6.5";

  src = fetchurl {
    url = "https://mango-lychee.nyc3.cdn.digitaloceanspaces.com/LycheeSlicer-${version}.AppImage";
    hash = "sha256-HVCAvukGeF4hRJ/l41iBV1MZD5i9qzIYGSgMrncNfDg=";
  };

  desktopItem = makeDesktopItem {
    categories = [ "Graphics" ];
    comment = "All-in-one 3D slicer for Resin and Filament";
    desktopName = "LycheeSlicer";
    exec = "lycheeslicer";
    genericName = "Resin Slicer";

    keywords = [
      "STL"
      "Slicer"
      "Printing"
    ];

    mimeTypes = [ "model/stl" ];
    name = "Lychee Slicer";
    noDisplay = false;
    terminal = false;
  };

in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm444 -t $out/share/applications ${desktopItem}/share/applications/*
  '';

  extraPkgs = _: [
    libxshmfence
    wayland
    wayland-protocols
  ];

  meta = {
    description = "All-in-one 3D slicer for resin and FDM printers";
    homepage = "https://lychee.mango3d.io/";
    license = lib.licenses.unfree;

    maintainers = with lib.maintainers; [
      tarinaky
      ZachDavies
    ];

    platforms = [ "x86_64-linux" ];
    mainProgram = "LycheeSlicer";
  };
}
