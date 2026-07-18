# Lean 4 package set with its own toolchain (independent of pkgs.lean4).
#
# Override the toolchain for the entire set:
#   leanPackages.overrideScope (self: super: { lean4 = lean4-custom; })
{
  lib,
  newScope,
}:

lib.makeScope newScope (self: {
  inherit (self.mathlib.passthru) mathlib__archive;
  Cli = self.callPackage ../development/lean-modules/Cli { };
  LeanSearchClient = self.callPackage ../development/lean-modules/LeanSearchClient { };
  Qq = self.callPackage ../development/lean-modules/Qq { };
  aesop = self.callPackage ../development/lean-modules/aesop { };
  batteries = self.callPackage ../development/lean-modules/batteries { };
  buildLakePackage = self.callPackage ../build-support/lake { };
  importGraph = self.callPackage ../development/lean-modules/importGraph { };
  lean4 = self.callPackage ../development/lean-modules/lean4 { };
  mathlib = self.callPackage ../development/lean-modules/mathlib { };
  plausible = self.callPackage ../development/lean-modules/plausible { };
  proofwidgets = self.callPackage ../development/lean-modules/proofwidgets { };
})
