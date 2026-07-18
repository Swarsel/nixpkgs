{
  lib,
  fetchzip,
}:
let
  /*
    see:
    https://github.com/Mastermindzh/tidal-hifi/blob/master/build/electron-builder.base.yml
     for the expected version
  */
  version = "41.5.0";
in
(fetchzip {
  hash = "sha256-LjM80c48AzEwoU8h07qUELTV5jjQeApanaoPZ/szdag=";
  stripRoot = false;
  url = "https://github.com/castlabs/electron-releases/releases/download/v${version}+wvcus/electron-v${version}+wvcus-linux-x64.zip";

}).overrideAttrs
  (
    final: _: {
      inherit version;
      pname = "castlabs-electron";
      name = "castlabs-electron-${version}";

      passthru = {
        src = final.finalPackage;
        dist = final.finalPackage.outPath;
      };

      meta = {
        license = lib.licenses.unfreeRedistributable;
        sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
      };
    }
  )
