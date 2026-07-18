{
  lib,
  nix-update-script,
  php,
  stdenvNoCC,
}@toplevel:

let
  buildComposerProjectOverride =
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
      doInstallCheck ? true,
      dontCheckForBrokenSymlinks ? true,
      meta ? { },
      nativeBuildInputs ? [ ],
      passthru ? { },
      patches ? [ ],
      php ? toplevel.php,
      strictDeps ? true,
      vendorHash ? "",
      ...
    }@args:
    {
      inherit
        patches
        strictDeps
        doCheck
        doInstallCheck
        dontCheckForBrokenSymlinks
        composerNoDev
        composerNoPlugins
        composerNoScripts
        ;

      nativeBuildInputs = nativeBuildInputs ++ [
        composer
        php
        php.composerHooks2.composerInstallHook
      ];

      buildInputs = buildInputs ++ [ php ];

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

      composerVendor =
        args.composerVendor or (php.mkComposerVendor {
          inherit (finalAttrs)
            pname
            src
            vendorHash
            version
            ;

          inherit
            php
            composer
            composerLock
            composerNoDev
            composerNoPlugins
            composerNoScripts
            composerStrictValidation
            dontCheckForBrokenSymlinks
            ;
        });

      # Should we keep these empty phases?
      configurePhase =
        args.configurePhase or ''
          runHook preConfigure

          runHook postConfigure
        '';

      # Projects providing a lockfile from upstream can be automatically updated.
      passthru = passthru // {
        updateScript =
          args.passthru.updateScript or (if composerLock == null then nix-update-script { } else null);
      };

      meta = meta // {
        platforms = lib.platforms.all;
      };
    };
in
lib.extendMkDerivation {
  constructDrv = stdenvNoCC.mkDerivation;
  extendDrvArgs = buildComposerProjectOverride;
}
