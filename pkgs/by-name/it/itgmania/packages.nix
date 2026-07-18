{ lib, newScope }:
lib.makeScope newScope (self: {
  # Themes
  arrowcloud-theme = self.callPackage ./themes/arrowcloud-theme.nix { };
  digital-dance = self.callPackage ./themes/digital-dance.nix { };
  itg2-sm5 = self.callPackage ./themes/itg2-sm5.nix { };
  itg3encore = self.callPackage ./themes/itg3encore.nix { };
  itgmania-unwrapped = self.callPackage ./unwrapped.nix { };
  zmod-simply-love = self.callPackage ./themes/zmod-simply-love.nix { };
})
