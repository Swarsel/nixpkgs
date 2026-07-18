{
  lib,
  factor-unwrapped,
  pkgs,
  overrides ? (self: super: { }),
}:

let
  inside =
    self:
    let
      callPackage = pkgs.newScope self;
    in
    lib.recurseIntoAttrs {

      inherit factor-unwrapped;
      # Vocabularies
      bresenham = callPackage ../development/factor-vocabs/bresenham { };

      buildFactorApplication =
        callPackage ../development/compilers/factor-lang/mk-factor-application.nix
          { };

      buildFactorVocab = callPackage ../development/compilers/factor-lang/mk-vocab.nix { };
      factor-lang = callPackage ../development/compilers/factor-lang/wrapper.nix { };

      factor-minimal = callPackage ../development/compilers/factor-lang/wrapper.nix {
        enableDefaults = false;
        guiSupport = false;
      };

      factor-minimal-gui = callPackage ../development/compilers/factor-lang/wrapper.nix {
        enableDefaults = false;
      };

      factor-no-gui = callPackage ../development/compilers/factor-lang/wrapper.nix {
        guiSupport = false;
      };

    }
    // lib.optionalAttrs pkgs.config.allowAliases {
      interpreter = throw "factorPackages now offers various wrapped factor runtimes (see documentation) and the buildFactorApplication helper.";
    };
  extensible-self = lib.makeExtensible (lib.extends overrides inside);
in
extensible-self
