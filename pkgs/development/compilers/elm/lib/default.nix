{
  lib,
  stdenv,
  elm,
  writeScriptBin,
}:
let
  patchNpmElm =
    pkg:
    pkg.override (old: {
      postInstall = (old.postInstall or "") + ''
        ln -sf ${elm}/bin/elm node_modules/elm/bin/elm
      '';

      preRebuild = (old.preRebuild or "") + ''
        rm node_modules/elm/install.js
        echo "console.log('Nixpkgs\' version of Elm will be used');" > node_modules/elm/install.js
      '';
    });
in
{
  inherit patchNpmElm;
}
