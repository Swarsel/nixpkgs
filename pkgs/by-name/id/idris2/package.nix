{
  lib,
  fetchFromGitHub,
  newScope,
}:
let
  idris2CompilerPackages = lib.makeScope newScope (
    self:
    let
      inherit (self) callPackage;
    in
    {
      base = callPackage ./base.nix { };
      contrib = callPackage ./contrib.nix { };

      idris2-src = fetchFromGitHub {
        hash = "sha256-MvFNSPpgONSTjACH3HGWEiNgz9aAeBPmyQwFe21+fe0=";
        owner = "idris-lang";
        repo = "Idris2";
        rev = "v${self.idris2-version}";
      };

      idris2-unwrapped = callPackage ./unwrapped.nix { };
      # Compiler version & repo
      idris2-version = "0.8.0";
      libidris2_support = callPackage ./libidris2_support.nix { };
      linear = callPackage ./linear.nix { };
      # Prelude libraries
      mkPrelude = callPackage ./mkPrelude.nix { }; # Build helper
      network = callPackage ./network.nix { };
      prelude = callPackage ./prelude.nix { };
      test = callPackage ./test.nix { };
    }
  );
in
idris2CompilerPackages.idris2-unwrapped.withPackages (_: [ ])
