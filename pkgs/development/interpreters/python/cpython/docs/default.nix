{
  lib,
  stdenv,
  fetchurl,
}:

let
  pythonDocs = {
    html = {
      python314 = import ./3.14-html.nix {
        inherit stdenv fetchurl lib;
      };

      recurseForDerivations = true;
    };

    texinfo = {
      python314 = import ./3.14-texinfo.nix {
        inherit stdenv fetchurl lib;
      };

      recurseForDerivations = true;
    };

    text = {
      python314 = import ./3.14-text.nix {
        inherit stdenv fetchurl lib;
      };

      recurseForDerivations = true;
    };
  };
in
pythonDocs
