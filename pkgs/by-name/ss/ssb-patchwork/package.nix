{
  lib,
  fetchurl,
  appimageTools,
  makeDesktopItem,
  symlinkJoin,
}:

let
  pname = "ssb-patchwork";
  version = "3.18.1";
  name = "Patchwork-${version}";

  src = fetchurl {
    url = "https://github.com/ssbc/patchwork/releases/download/v${version}/${name}.AppImage";
    sha256 = "F8n6LLbgkg3z55lSY60T+pn2lra8aPt6Ztepw1gf2rI=";
  };

  binary = appimageTools.wrapType2 {
    inherit pname version src;
  };
  # we only use this to extract the icon
  appimage-contents = appimageTools.extractType2 {
    inherit pname version src;
  };

  desktopItem = makeDesktopItem {
    categories = [ "Network" ];
    comment = "Client for the decentralized social network Secure Scuttlebutt";
    desktopName = "Patchwork";
    exec = "${binary}/bin/ssb-patchwork";
    genericName = "Patchwork";
    icon = "ssb-patchwork";
    name = "ssb-patchwork";
  };

in
symlinkJoin {
  inherit version;
  pname = "patchwork";

  postBuild = ''
    mkdir -p $out/share/applications
    install -D ${appimage-contents}/ssb-patchwork.png -t $out/share/icons/hicolor/512x512/apps
    cp ${desktopItem}/share/applications/* $out/share/applications/
  '';

  paths = [ binary ];

  meta = {
    description = "Decentralized messaging and sharing app built on top of Secure Scuttlebutt (SSB)";

    longDescription = ''
      sea-slang for gossip - a scuttlebutt is basically a watercooler on a ship.
    '';

    homepage = "https://www.scuttlebutt.nz/";
    license = lib.licenses.agpl3Only;

    maintainers = with lib.maintainers; [
      asymmetric
      picnoir
      cyplo
    ];

    platforms = [ "x86_64-linux" ];
    mainProgram = "ssb-patchwork";
  };
}
