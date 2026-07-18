{ newScope }:

let
  callPackage = newScope self;

  stable = rec {
    curses = tiles.override { tiles = false; };
    tiles = callPackage ./stable.nix { };
  };

  git = rec {
    curses = tiles.override { tiles = false; };
    tiles = callPackage ./git.nix { };
  };

  lib = callPackage ./lib.nix { };

  pkgs = callPackage ./pkgs { };

  self = {
    inherit
      callPackage
      stable
      git
      ;

    inherit (lib)
      buildMod
      buildSoundPack
      buildTileSet
      wrapCDDA
      attachPkgs
      ;

    inherit pkgs;
  };
in

self
