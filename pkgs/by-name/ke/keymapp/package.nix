{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  callPackage,
  copyDesktopItems,
  libsoup_3,
  libusb1,
  makeDesktopItem,
  undmg,
  webkitgtk_4_1,
  wrapGAppsHook4,
}:
let
  pname = "keymapp";
  version = "1.3.7";

  sources = rec {
    aarch64-darwin = {
      hash = "sha256-H6xRau7pWuSF5Aa6lblwi/Lg5KxC+HM3rtUMjX+hEE8=";
      url = "https://oryx.nyc3.cdn.digitaloceanspaces.com/keymapp/keymapp-${version}.dmg";
    };

    aarch64-linux = {
      hash = "sha256-qHvHCDzWRhuhDg2kuU8kmikQDXElQtVEmPAelHz4aPo=";
      url = "https://oryx.nyc3.cdn.digitaloceanspaces.com/keymapp/keymapp-${version}.tar.gz";
    };

    x86_64-linux = aarch64-linux;
  };
  src = fetchurl {
    inherit (sources.${stdenv.system} or (throw "Unsupported system: ${stdenv.system}")) url hash;
  };

  meta = {
    description = "Application for ZSA keyboards";
    homepage = "https://www.zsa.io/flash/";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];

    maintainers = with lib.maintainers; [
      afh
      jankaifer
      shawn8901
    ];

    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };

in
if stdenv.hostPlatform.isDarwin then
  callPackage ./darwin.nix {
    inherit
      pname
      version
      src
      meta
      undmg
      ;
  }
else
  callPackage ./linux.nix {
    inherit
      pname
      version
      src
      meta
      libusb1
      libsoup_3
      webkitgtk_4_1
      autoPatchelfHook
      wrapGAppsHook4
      copyDesktopItems
      makeDesktopItem
      ;
  }
