{
  lib,
  stdenv,
  fetchurl,
  appimageTools,
  callPackage,
}:
let
  pname = "immersed";
  version = "11.0.0";

  sources = lib.mapAttrs (_: fetchurl) {
    aarch64-darwin = {
      hash = "sha256-L5nrkchXD1NIQCknYHVhBWbVJVkkHvKaDjuk9qiY340=";
      url = "https://web.archive.org/web/20260306043741/https://static.immersed.com/dl/Immersed.dmg";
    };

    aarch64-linux = {
      hash = "sha256-3BokV30y6QRjE94K7JQ6iIuQw1t+h3BKZY+nEFGTVHI=";
      url = "https://web.archive.org/web/20260306043741/https://static.immersed.com/dl/Immersed-aarch64.AppImage";
    };

    x86_64-linux = {
      hash = "sha256-GbckZ/WK+7/PFQvTfUwwePtufPKVwIwSPh+Bo/cG7ko=";
      url = "https://web.archive.org/web/20260306043741/https://static.immersed.com/dl/Immersed-x86_64.AppImage";
    };
  };

  src = sources.${stdenv.system} or (throw "Unsupported system: ${stdenv.system}");

  meta = {
    description = "VR coworking platform";
    homepage = "https://immersed.com";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      pandapip1
      crertel
    ];

    platforms = builtins.attrNames sources;
  };

in

(
  if stdenv.hostPlatform.isDarwin then
    callPackage ./darwin.nix {
      inherit
        pname
        version
        src
        meta
        ;
    }
  else
    callPackage ./linux.nix {
      inherit
        pname
        version
        src
        meta
        ;
    }
)
// {
  passthru = {
    inherit sources;
  };
}
