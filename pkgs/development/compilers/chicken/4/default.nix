{ lib, newScope }:
let
  callPackage = newScope self;

  self = {
    chicken = callPackage ./chicken.nix {
      bootstrap-chicken = self.chicken.override { bootstrap-chicken = null; };
    };

    chickenEggs = lib.recurseIntoAttrs (callPackage ./eggs.nix { });
    egg2nix = callPackage ./egg2nix.nix { };
    eggDerivation = callPackage ./eggDerivation.nix { };
    fetchegg = callPackage ./fetchegg { };

    pkgs = self // {
      recurseForDerivations = false;
    };
  };

in
self
