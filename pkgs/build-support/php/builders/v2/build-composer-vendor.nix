{
  lib,
  php,
  stdenvNoCC,
}@toplevel:

let
  mkComposerVendorOverride =
    finalAttrs:
    {
      buildInputs ? [ ],
      composer ? php.packages.composer,
      composerLock ? null,
      composerNoDev ? true,
      composerNoPlugins ? true,
      composerNoScripts ? true,
      composerStrictValidation ? true,
      doCheck ? true,
      doInstallCheck ? false,
      dontCheckForBrokenSymlinks ? true,
      dontPatchShebangs ? true,
      nativeBuildInputs ? [ ],
      php ? toplevel.php,
      strictDeps ? true,
      vendorHash ? "",
      ...
    }@args:
    assert args ? pname || throw "mkComposerVendor expects pname argument.";
    assert args ? version || throw "mkComposerVendor expects version argument.";
    assert args ? src || throw "mkComposerVendor expects src argument.";
    {
      # See https://github.com/NixOS/nix/issues/6660
      inherit dontPatchShebangs;

      inherit
        buildInputs
        strictDeps
        doCheck
        ;

      nativeBuildInputs = nativeBuildInputs ++ [
        composer
        php
        php.composerHooks2.composerVendorHook
      ];

      buildPhase =
        args.buildPhase or ''
          runHook preBuild

          runHook postBuild
        '';

      checkPhase =
        args.checkPhase or ''
          runHook preCheck

          runHook postCheck
        '';

      installPhase =
        args.installPhase or ''
          runHook preInstall

          runHook postInstall
        '';

      installCheckPhase =
        args.installCheckPhase or ''
          runHook preInstallCheck

          runHook postInstallCheck
        '';

      # Should we keep these empty phases?
      configurePhase =
        args.configurePhase or ''
          runHook preConfigure

          runHook postConfigure
        '';

      name = "${args.pname}-composer-vendor-${args.version}";
      outputHash = vendorHash;

      outputHashAlgo =
        if (finalAttrs ? vendorHash && finalAttrs.vendorHash != "") then null else "sha256";

      outputHashMode = "recursive";
    };
in
lib.extendMkDerivation {
  constructDrv = stdenvNoCC.mkDerivation;
  extendDrvArgs = mkComposerVendorOverride;
}
