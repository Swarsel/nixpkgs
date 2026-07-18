{
  lib,
  fetchFromGitHub,
  atdgen,
  buildDunePackage,
  junit,
  newScope,
  ppxlib,
  qcheck-core,
  re,
  reason,
}:

lib.makeScope newScope (self: {
  inherit
    lib
    buildDunePackage
    re
    reason
    ppxlib
    ;

  # Upstream doesn't use tags, releases, or branches.
  src = fetchFromGitHub {
    owner = "reasonml";
    repo = "reason-native";
    # When updating this make sure to also update the `version` above
    rev = "20b1997b6451d9715dfdbeec86a9d274c7430ed8";
    hash = "sha256-96Ucq70eSy6pqh5ne9xoODWe/nPuriZnFAdx0OkLVCs=";
    pname = "reason-native";
    version = "0-unstable-2024-05-07";

    meta = {
      license = lib.licenses.mit;
    };
  };

  cli = self.callPackage ./cli.nix { };
  console = self.callPackage ./console.nix { };
  dir = self.callPackage ./dir.nix { };
  file-context-printer = self.callPackage ./file-context-printer.nix { };
  fp = self.callPackage ./fp.nix { };
  frame = self.callPackage ./frame.nix { };
  fs = self.callPackage ./fs.nix { };
  pastel = self.callPackage ./pastel.nix { };
  pastel-console = self.callPackage ./pastel-console.nix { };

  qcheck-rely = self.callPackage ./qcheck-rely.nix {
    inherit qcheck-core;
  };

  refmterr = self.callPackage ./refmterr.nix {
    inherit atdgen;
  };

  rely = self.callPackage ./rely.nix { };

  rely-junit-reporter = self.callPackage ./rely-junit-reporter.nix {
    inherit atdgen junit;
  };

  unicode = self.callPackage ./unicode.nix { };
  unicode-config = self.callPackage ./unicode-config.nix { };
  utf8 = self.callPackage ./utf8.nix { };
})
