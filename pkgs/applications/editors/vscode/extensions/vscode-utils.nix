{
  lib,
  stdenv,
  fetchurl,
  buildEnv,
  buildPackages,
  jq,
  makeSetupHook,
  unzip,
  vscode,
  vscode-extension-update-script,
  writeScript,
  writeShellScriptBin,
}:
let
  unpackVsixSetupHook = makeSetupHook {
    name = "unpack-vsix-setup-hook";

    substitutions = {
      unzip = "${buildPackages.unzip}/bin/unzip";
    };

    meta.license = lib.licenses.mit;
  } ./unpack-vsix-setup-hook.sh;
  buildVscodeExtension = lib.extendMkDerivation {
    constructDrv = stdenv.mkDerivation;

    excludeDrvArgNames = [
      "vscodeExtUniqueId"
    ];

    extendDrvArgs =
      finalAttrs:
      {
        vscodeExtName,
        # Same as "Unique Identifier" on the extension's web page.
        # For the moment, only serve as unique extension dir.
        vscodeExtPublisher,
        vscodeExtUniqueId,
        buildPhase ? ''
          runHook preBuild
          runHook postBuild
        '',
        configurePhase ? ''
          runHook preConfigure
          runHook postConfigure
        '',
        dontPatchELF ? true,
        dontStrip ? true,
        nativeBuildInputs ? [ ],
        passthru ? { },
        pname ? null, # Only optional for backward compatibility.
        ...
      }@args:
      {
        inherit
          configurePhase
          buildPhase
          dontPatchELF
          dontStrip
          ;

        pname = "vscode-extension-${pname}";
        nativeBuildInputs = [ unpackVsixSetupHook ] ++ nativeBuildInputs;

        installPhase =
          args.installPhase or ''
            runHook preInstall

            mkdir -p "$out/$installPrefix"
            find . -mindepth 1 -maxdepth 1 | xargs -d'\n' mv -t "$out/$installPrefix/"

            runHook postInstall
          '';

        # This cannot be removed, it is used by some extensions.
        installPrefix = "share/vscode/extensions/${vscodeExtUniqueId}";
        # Some .vsix files contain other directories (e.g., `package`) that we don't use.
        # If other directories are present but `sourceRoot` is unset, the unpacker phase fails.
        sourceRoot = args.sourceRoot or "extension";

        passthru = {
          updateScript = vscode-extension-update-script { };
        }
        // passthru
        // {
          inherit vscodeExtPublisher vscodeExtName vscodeExtUniqueId;
        };
      };
  };

  fetchVsixFromVscodeMarketplace =
    mktplcExtRef: fetchurl (import ./mktplcExtRefToFetchArgs.nix mktplcExtRef);

  buildVscodeMarketplaceExtension = lib.extendMkDerivation {
    constructDrv = buildVscodeExtension;

    excludeDrvArgNames = [
      "mktplcRef"
      "vsix"
    ];

    extendDrvArgs =
      finalAttrs:
      {
        mktplcRef,
        name ? "",
        src ? null,
        vsix ? null,
        ...
      }:
      assert "" == name;
      assert null == src;
      {
        inherit (mktplcRef) version;
        pname = "${mktplcRef.publisher}-${mktplcRef.name}";
        src = if (vsix != null) then vsix else fetchVsixFromVscodeMarketplace mktplcRef;
        vscodeExtName = mktplcRef.name;
        vscodeExtPublisher = mktplcRef.publisher;
        vscodeExtUniqueId = "${mktplcRef.publisher}.${mktplcRef.name}";
      };
  };

  mktplcRefAttrList = [
    "name"
    "publisher"
    "version"
    "sha256"
    "hash"
    "arch"
  ];

  mktplcExtRefToExtDrv =
    ext:
    buildVscodeMarketplaceExtension (
      removeAttrs ext mktplcRefAttrList
      // {
        mktplcRef = builtins.intersectAttrs (lib.genAttrs mktplcRefAttrList (_: null)) ext;
      }
    );

  extensionFromVscodeMarketplace = mktplcExtRefToExtDrv;
  extensionsFromVscodeMarketplace =
    mktplcExtRefList: map extensionFromVscodeMarketplace mktplcExtRefList;

  vscodeWithConfiguration = import ./vscodeWithConfiguration.nix {
    inherit lib extensionsFromVscodeMarketplace writeShellScriptBin;
    vscodeDefault = vscode;
  };

  vscodeExts2nix = import ./vscodeExts2nix.nix {
    inherit lib writeShellScriptBin;
    vscodeDefault = vscode;
  };

  vscodeEnv = import ./vscodeEnv.nix {
    inherit
      lib
      buildEnv
      writeShellScriptBin
      extensionsFromVscodeMarketplace
      jq
      ;

    vscodeDefault = vscode;
  };

  toExtensionJsonEntry = ext: rec {
    version = ext.version;

    identifier = {
      id = ext.vscodeExtUniqueId;
      uuid = "";
    };

    location = {
      "$mid" = 1;
      fsPath = ext.outPath + "/share/vscode/extensions/${ext.vscodeExtUniqueId}";
      path = location.fsPath;
      scheme = "file";
    };

    metadata = {
      id = "";
      installedTimestamp = 0;
      isApplicationScoped = false;
      isPreReleaseVersion = false;
      preRelease = false;
      publisherDisplayName = ext.vscodeExtPublisher;
      publisherId = "";
      targetPlatform = "undefined";
      updated = false;
    };

    relativeLocation = ext.vscodeExtUniqueId;
  };

  toExtensionJson = extensions: builtins.toJSON (map toExtensionJsonEntry extensions);
in
{
  inherit
    fetchVsixFromVscodeMarketplace
    buildVscodeExtension
    buildVscodeMarketplaceExtension
    extensionFromVscodeMarketplace
    extensionsFromVscodeMarketplace
    vscodeWithConfiguration
    vscodeExts2nix
    vscodeEnv
    toExtensionJsonEntry
    toExtensionJson
    ;
}
