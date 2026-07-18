# package.el-based emacs packages

## FOR USERS
#
# Recommended: simply use `emacsWithPackages` with the packages you want.
#
# Alternative: use `emacs`, install everything to a system or user profile
# and then add this at the start your `early-init.el`:
/*
  ;; optional. use this if you install emacs packages to the system profile
  (add-to-list 'package-directory-list "/run/current-system/sw/share/emacs/site-lisp/elpa")

  ;; optional. use this if you install emacs packages to user profiles (with nix-env)
  (add-to-list 'package-directory-list "~/.nix-profile/share/emacs/site-lisp/elpa")
*/

{
  lib,
  emacs',
  pkgs',
}:

let

  mkElpaDevelPackages =
    { lib, pkgs }:
    import ../applications/editors/emacs/elisp-packages/elpa-devel-packages.nix {
      inherit (pkgs) pkgs buildPackages;
      inherit lib;
    };

  mkElpaPackages =
    { lib, pkgs }:
    import ../applications/editors/emacs/elisp-packages/elpa-packages.nix {
      inherit (pkgs) pkgs buildPackages;
      inherit lib;
    };

  mkNongnuDevelPackages =
    { lib, pkgs }:
    import ../applications/editors/emacs/elisp-packages/nongnu-devel-packages.nix {
      inherit (pkgs) pkgs buildPackages;
      inherit lib;
    };

  mkNongnuPackages =
    { lib, pkgs }:
    import ../applications/editors/emacs/elisp-packages/nongnu-packages.nix {
      inherit (pkgs) pkgs buildPackages;
      inherit lib;
    };

  # Contains both melpa stable & unstable
  melpaGeneric =
    { lib, pkgs }:
    import ../applications/editors/emacs/elisp-packages/melpa-packages.nix {
      inherit lib pkgs;
    };

  mkManualPackages =
    { lib, pkgs }:
    import ../applications/editors/emacs/elisp-packages/manual-packages.nix {
      inherit lib pkgs;
    };

  emacsWithPackages =
    { lib, pkgs }:
    pkgs.callPackage ../applications/editors/emacs/build-support/wrapper.nix {
      inherit (pkgs) lndir;
      inherit lib;
    };

in
lib.makeScope pkgs'.newScope (
  self:
  lib.makeOverridable (
    {
      lib ? pkgs.lib,
      elpaDevelPackages ? mkElpaDevelPackages { inherit pkgs lib; } self,
      elpaPackages ? mkElpaPackages { inherit pkgs lib; } self,
      manualPackages ? mkManualPackages { inherit pkgs lib; } self,
      melpaPackages ? melpaGeneric { inherit pkgs lib; } "unstable" self,
      melpaStablePackages ? melpaGeneric { inherit pkgs lib; } "stable" self,
      nongnuDevelPackages ? mkNongnuDevelPackages { inherit pkgs lib; } self,
      nongnuPackages ? mkNongnuPackages { inherit pkgs lib; } self,
      pkgs ? pkgs',
    }:
    (
      { }
      // elpaDevelPackages
      // {
        inherit elpaDevelPackages;
      }
      // elpaPackages
      // {
        inherit elpaPackages;
      }
      // nongnuDevelPackages
      // {
        inherit nongnuDevelPackages;
      }
      // nongnuPackages
      // {
        inherit nongnuPackages;
      }
      // melpaStablePackages
      // {
        inherit melpaStablePackages;
      }
      // melpaPackages
      // {
        inherit melpaPackages;
      }
      // manualPackages
      // {
        inherit manualPackages;
      }
      // {

        elpaBuild = pkgs.callPackage ../applications/editors/emacs/build-support/elpa.nix {
          inherit (self) emacs;
        };

        # Propagate overridden scope
        emacs = emacs'.overrideAttrs (old: {
          passthru = (old.passthru or { }) // {
            pkgs = lib.dontRecurseIntoAttrs self;
          };
        });

        emacsWithPackages = emacsWithPackages { inherit pkgs lib; } self;

        melpaBuild = pkgs.callPackage ../applications/editors/emacs/build-support/melpa.nix {
          inherit (self) emacs;
        };

        trivialBuild = pkgs.callPackage ../applications/editors/emacs/build-support/trivial.nix {
          inherit (self) emacs;
        };

        withPackages = emacsWithPackages { inherit pkgs lib; } self;

      }
      // {

        # Package specific priority overrides goes here

        # EXWM is not tagged very often, prefer it from elpa devel.
        inherit (elpaDevelPackages) exwm;
        # Telega uploads packages incompatible with stable tdlib to melpa
        # Prefer the one from melpa stable
        inherit (melpaStablePackages) telega;

      }
    )
  ) { }
)
