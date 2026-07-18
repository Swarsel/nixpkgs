{
  lib,
  fetchurl,
  appimageTools,
  makeDesktopItem,
}:

let
  pname = "MyCrypto";
  version = "1.7.17";
  sha256 = "20eb48989b5ae5e60e438eff6830ac79a0d89ac26dff058097260e747e866444"; # Taken from release's checksums.txt.gpg

  src = fetchurl {
    inherit sha256;
    url = "https://github.com/mycryptohq/mycrypto/releases/download/${version}/linux-x86-64_${version}_MyCrypto.AppImage";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };

  desktopItem = makeDesktopItem {
    categories = [ "Finance" ];
    comment = "MyCrypto is a free, open-source interface for interacting with the blockchain";
    desktopName = pname;
    exec = pname;
    icon = "mycrypto";
    name = pname;
  };

in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    mkdir -p $out/share
    cp -rt $out/share ${desktopItem}/share/applications ${appimageContents}/usr/share/icons
    chmod -R +w $out/share
    mv $out/share/icons/hicolor/{0x0,256x256}
  '';

  meta = {
    description = "Free, open-source interface for interacting with the blockchain";

    longDescription = ''
      MyCrypto is an open-source, client-side tool for generating ether wallets,
      handling ERC-20 tokens, and interacting with the blockchain more easily.
    '';

    homepage = "https://mycrypto.com";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "MyCrypto";
  };
}
