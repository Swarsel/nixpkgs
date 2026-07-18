{
  lib,
  fetchurl,
  appimageTools,
  copyDesktopItems,
  imagemagick,
  makeDesktopItem,
  nix-update,
  runCommand,
  writeShellScript,
}:
let
  icon =
    runCommand "xnviewmp-icon.png"
      {
        src = fetchurl {
          url = "https://www.xnview.com/img/app-xnsoft-360.webp";
          hash = "sha256-wIzF/WOsPcrYFYC/kGZi6FSJFuErci5EMONjrx1VCdQ=";
        };

        nativeBuildInputs = [ imagemagick ];
      }
      ''
        magick $src -resize 512x512 $out
      '';
in
appimageTools.wrapType2 rec {
  pname = "xnviewmp";
  version = "1.11.2";

  src = fetchurl {
    url = "https://download.xnview.com/old_versions/XnView_MP/XnView_MP-${version}.glibc2.17-x86_64.AppImage";
    hash = "sha256-czgleryYMhRKxnv7Qb3E03iZ4mKXaz//jz7HmuQbjIc=";
  };

  nativeBuildInputs = [
    copyDesktopItems
  ];

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Graphics" ];
      comment = "An efficient multimedia viewer, browser and converter";
      desktopName = "XnView MP";
      exec = "xnviewmp %F";
      icon = "xnviewmp";
      name = "xnviewmp";
    })
  ];

  extraInstallCommands = ''
    install -m 444 -D ${icon} $out/share/icons/hicolor/512x512/apps/xnviewmp.png
  '';

  extraPkgs = pkgs: [
    pkgs.qt5.qtbase
  ];

  passthru = {
    inherit src;

    updateScript = writeShellScript "update-xnviewmp" ''
      latestVersion=$(curl --fail --silent "http://www.xnview.com/update.txt" | awk -F= '/\[XnViewMP\]/{getline; if($1=="version") print $2}')
      ${lib.getExe nix-update} xnviewmp --version $latestVersion
    '';
  };

  meta = {
    description = "Efficient multimedia viewer, browser and converter";
    homepage = "https://www.xnview.com/en/xnviewmp/";
    changelog = "https://www.xnview.com/mantisbt/changelog_page.php";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = with lib.maintainers; [ oddlama ];
    platforms = lib.platforms.linux;
    mainProgram = "xnviewmp";
    downloadPage = "https://download.xnview.com/old_versions/XnView_MP/";
  };
}
