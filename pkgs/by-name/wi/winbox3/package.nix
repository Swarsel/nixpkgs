{
  lib,
  fetchurl,
  copyDesktopItems,
  makeBinaryWrapper,
  makeDesktopItem,
  stdenvNoCC,
  wineWow64Packages,
}:

let
  wine = wineWow64Packages.stable;
  # The icon is also from the winbox AUR package (see above).
  icon = fetchurl {
    hash = "sha256-YD6u2N+1thRnEsXO6AHm138fRda9XEtUX5+EGTg004A=";
    name = "winbox.png";
    url = "https://aur.archlinux.org/cgit/aur.git/plain/winbox.png?h=winbox";
  };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "winbox";
  version = "3.43";

  src = fetchurl (
    if (builtins.elem "i686-linux" wine.meta.platforms) then
      {
        url = "https://download.mikrotik.com/routeros/winbox/${finalAttrs.version}/winbox.exe";
        hash = "sha256-pAOOTgmjQoXI2o2MKTDuOOpb7q0rb/zWATDNyAMOLms=";
      }
    else
      {
        url = "https://download.mikrotik.com/routeros/winbox/${finalAttrs.version}/winbox64.exe";
        hash = "sha256-W0HPUf2B6NCCaH9rUiFZz0q6IubfjtxIZyHU4JUHtuk=";
      }
  );

  nativeBuildInputs = [
    makeBinaryWrapper
    copyDesktopItems
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,libexec}

    install -D "${icon}" "$out/share/icons/hicolor/128x128/apps/winbox.png"

    makeWrapper ${lib.getExe wine} $out/bin/winbox \
      --add-flags $src

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Utility" ];
      comment = "GUI administration for Mikrotik RouterOS";
      desktopName = "Winbox";
      exec = "winbox";
      icon = "winbox";
      name = "winbox";
    })
  ];

  dontUnpack = true;

  meta = {
    description = "Graphical configuration utility for RouterOS-based devices";
    homepage = "https://mikrotik.com";
    changelog = "https://wiki.mikrotik.com/wiki/Winbox_changelog";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ yrd ];
    mainProgram = "winbox";
    downloadPage = "https://mikrotik.com/download";
  };
})
