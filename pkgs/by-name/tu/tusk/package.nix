{
  lib,
  fetchurl,
  appimageTools,
  makeDesktopItem,
}:

let
  pname = "tusk";
  version = "0.23.0";

  icon = fetchurl {
    sha256 = "1jqclyrjgg6hir45spg75plfmd8k9nrsrzw3plbcg43s5m1qzihb";
    url = "https://raw.githubusercontent.com/klaussinani/tusk/v${version}/static/Icon.png";
  };

  desktopItem = makeDesktopItem {
    categories = [ "Application" ];
    desktopName = pname;
    exec = pname;
    genericName = "Evernote desktop app";
    icon = icon;
    name = pname;
  };

in
appimageTools.wrapType2 rec {
  inherit pname version;

  src = fetchurl {
    url = "https://github.com/klaussinani/tusk/releases/download/v${version}/tusk-${version}-x86_64.AppImage";
    sha256 = "02q7wsnhlyq8z74avflrm7805ny8fzlmsmz4bmafp4b4pghjh5ky";
  };

  extraInstallCommands = ''
    mkdir "$out/share"
    ln -s "${desktopItem}/share/applications" "$out/share/"
  '';

  profile = ''
    export LC_ALL=C.UTF-8
  '';

  meta = {
    description = "Refined Evernote desktop app";

    longDescription = ''
      Tusk is an unofficial, featureful, open source, community-driven, free Evernote app used by people in more than 140 countries. Tusk is indicated by Evernote as an alternative client for Linux environments trusted by the open source community.
    '';

    homepage = "https://klaussinani.github.io/tusk/";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "tusk";
  };
}
