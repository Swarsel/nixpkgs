{
  lib,
  cacert,
  makeBinaryWrapper,
  nix-update-script,
  php,
  stdenvNoCC,
  writeText,
}:

let
  composerJsonBuilder =
    pluginName: pluginVersion:
    writeText "composer.json" (
      builtins.toJSON {
        config = {
          "allow-plugins" = {
            "${pluginName}" = true;
          };
        };

        description = "Nix Composer plugin";
        license = "MIT";
        name = "nix/plugin";

        repositories = [
          {
            options = {
              versions = {
                "${pluginName}" = "${pluginVersion}";
              };
            };

            type = "path";
            url = "./src";
          }
        ];

        require = {
          "${pluginName}" = "${pluginVersion}";
        };
      }
    );

  buildComposerWithPluginOverride =
    finalAttrs: previousAttrs:

    let
      phpDrv = finalAttrs.php or php;
      composer = finalAttrs.composer or phpDrv.packages.composer;
    in
    {
      patches = previousAttrs.patches or [ ];
      strictDeps = previousAttrs.strictDeps or true;

      nativeBuildInputs = (previousAttrs.nativeBuildInputs or [ ]) ++ [
        composer
        phpDrv
        makeBinaryWrapper
      ];

      buildInputs = (previousAttrs.buildInputs or [ ]) ++ [ phpDrv ];

      buildPhase =
        previousAttrs.buildPhase or ''
          runHook preBuild

          runHook postBuild
        '';

      doCheck = previousAttrs.doCheck or true;

      checkPhase =
        previousAttrs.checkPhase or ''
          runHook preCheck

          runHook postCheck
        '';

      installPhase =
        previousAttrs.installPhase or ''
            runHook preInstall

          makeWrapper ${lib.getExe composer} $out/bin/composer \
            --prefix COMPOSER_HOME : ${finalAttrs.vendor}

            runHook postInstall
        '';

      doInstallCheck = previousAttrs.doInstallCheck or false;

      installCheckPhase =
        previousAttrs.installCheckPhase or ''
          runHook preInstallCheck

          composer global show ${finalAttrs.pname}

          runHook postInstallCheck
        '';

      composerGlobal = true;
      composerLock = previousAttrs.composerLock or null;
      composerNoDev = previousAttrs.composerNoDev or true;
      composerNoPlugins = previousAttrs.composerNoPlugins or true;
      composerNoScripts = previousAttrs.composerNoScripts or true;
      composerStrictValidation = previousAttrs.composerStrictValidation or true;

      # Should we keep these empty phases?
      configurePhase =
        previousAttrs.configurePhase or ''
          runHook preConfigure

          runHook postConfigure
        '';

      vendor = previousAttrs.vendor or stdenvNoCC.mkDerivation {
        inherit (finalAttrs) version src;
        pname = "${finalAttrs.pname}-vendor";

        nativeBuildInputs = [
          cacert
          composer
          phpDrv.composerHooks.composerWithPluginVendorHook
        ];

        env = {
          COMPOSER_CACHE_DIR = "/dev/null";
          COMPOSER_HTACCESS_PROTECT = "0";
        };

        doCheck = true;
        doInstallCheck = true;
        composerGlobal = true;
        composerJson = composerJsonBuilder finalAttrs.pname finalAttrs.version;
        composerLock = previousAttrs.composerLock or null;
        composerNoDev = previousAttrs.composerNoDev or true;
        composerNoPlugins = previousAttrs.composerNoPlugins or true;
        composerNoScripts = previousAttrs.composerNoScripts or true;
        composerStrictValidation = previousAttrs.composerStrictValidation or true;
        dontPatchShebangs = true;
        outputHash = finalAttrs.vendorHash;
        outputHashAlgo = "sha256";
        outputHashMode = "recursive";
        pluginName = finalAttrs.pname;
      };

      # Projects providing a lockfile from upstream can be automatically updated.
      passthru = previousAttrs.passthru or { } // {
        updateScript =
          previousAttrs.passthru.updateScript
            or (if finalAttrs.vendor.composerLock == null then nix-update-script { } else null);
      };

      meta = previousAttrs.meta or composer.meta;
    };
in
args: (stdenvNoCC.mkDerivation args).overrideAttrs buildComposerWithPluginOverride
