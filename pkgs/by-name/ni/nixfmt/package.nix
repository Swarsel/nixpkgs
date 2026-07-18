{
  lib,
  stdenv,
  haskell,
  haskellPackages,
  versionCheckHook,
}:
let
  inherit (haskell.lib.compose) overrideCabal justStaticExecutables;

  cabalOverrides = drv: {
    changelog = "https://github.com/NixOS/nixfmt/releases/tag/v${drv.version}";
    teams = [ lib.teams.formatter ];
    passthru.updateScript = ./update.sh;
  };

  # haskellPackages.mkDerivation and haskell.lib.compose.overrideCabal
  # do not allow access to `doInstallCheck` or `nativeInstallCheckInputs`,
  # so we override directly with `.overrideAttrs`.
  lateOverrides = finalAttrs: prevAttrs: {
    doInstallCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

    nativeInstallCheckInputs = prevAttrs.nativeInstallCheckInputs or [ ] ++ [
      versionCheckHook
    ];
  };

  raw-pkg = haskellPackages.callPackage ./generated-package.nix { };
in
lib.pipe raw-pkg [
  (overrideCabal cabalOverrides)
  justStaticExecutables
  (drv: drv.overrideAttrs lateOverrides)
]
