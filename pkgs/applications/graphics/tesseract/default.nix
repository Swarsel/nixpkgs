{
  lib,
  callPackage,
}:

let
  inherit (lib) lowPrio;
  base3 = callPackage ./tesseract3.nix { };
  base4 = callPackage ./tesseract4.nix { };
  base5 = callPackage ./tesseract5.nix { };
  languages = callPackage ./languages.nix { };
in
{
  tesseract3 = callPackage ./wrapper.nix {
    languages = languages.v3;
    tesseractBase = base3;
  };

  tesseract4 = lowPrio (
    callPackage ./wrapper.nix {
      languages = languages.v4;
      tesseractBase = base4;
    }
  );

  tesseract5 = lowPrio (
    callPackage ./wrapper.nix {
      languages = languages.v4;
      tesseractBase = base5;
    }
  );
}
