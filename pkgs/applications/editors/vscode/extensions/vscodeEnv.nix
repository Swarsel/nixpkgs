#Use vscodeWithConfiguration and vscodeExts2nix to create a vscode executable. When the executable exits, it updates the mutable extension file, which is imported when evaluated by Nix later.
{
  lib,
  buildEnv,
  extensionsFromVscodeMarketplace,
  jq,
  vscodeDefault,
  writeShellScriptBin,
}:
##User input
{
  # if file exists will use it and import the extensions in it into this derivation else will use empty extensions list
  # this file will be created/updated by vscodeExts2nix when vscode exists
  mutableExtensionsFile,
  createKeybindingsIfDoesNotExists ? true,
  createLaunchIfDoesNotExists ? true,
  createSettingsIfDoesNotExists ? true,
  # will add to the command updateKeybindings(which will run on executing vscode) keybindings to override in keybinding.json file
  keybindings ? { },
  launch ? { },
  nixExtensions ? [ ],
  # will add to the command updateSettings (which will run on executing vscode) settings to override in settings.json file
  settings ? { },
  user-data-dir ? ''"''${TMP}''${name}"/vscode-data-dir'',
  vscode ? vscodeDefault,
  vscodeExtsFolderName ? ".vscode-exts",
}:
let
  mutableExtensionsFilePath = toString mutableExtensionsFile;
  mutableExtensions = lib.optionals (builtins.pathExists mutableExtensionsFile) (
    import mutableExtensionsFilePath
  );
  vscodeWithConfiguration =
    import ./vscodeWithConfiguration.nix
      {
        inherit lib writeShellScriptBin extensionsFromVscodeMarketplace;
        vscodeDefault = vscode;
      }
      {
        inherit
          nixExtensions
          mutableExtensions
          vscodeExtsFolderName
          user-data-dir
          ;
      };

  updateSettings = import ./updateSettings.nix { inherit lib writeShellScriptBin jq; };
  userSettingsFolder = "${user-data-dir}/User";

  updateSettingsCmd = updateSettings {
    inherit userSettingsFolder;
    createIfDoesNotExists = createSettingsIfDoesNotExists;

    settings = {
      "extensions.autoCheckUpdates" = false;
      "extensions.autoUpdate" = false;
      "update.mode" = "none";
    }
    // settings;

    symlinkFromUserSetting = (user-data-dir != "");
  };

  updateLaunchCmd = updateSettings {
    createIfDoesNotExists = createLaunchIfDoesNotExists;
    settings = launch;
    vscodeSettingsFile = ".vscode/launch.json";
  };

  updateKeybindingsCmd = updateSettings {
    inherit userSettingsFolder;
    createIfDoesNotExists = createKeybindingsIfDoesNotExists;
    settings = keybindings;
    symlinkFromUserSetting = (user-data-dir != "");
    vscodeSettingsFile = ".vscode/keybindings.json";
  };

  vscodeExts2nix =
    import ./vscodeExts2nix.nix
      {
        inherit lib writeShellScriptBin;
        vscodeDefault = vscodeWithConfiguration;
      }
      {
        extensions = mutableExtensions;
        extensionsToIgnore = nixExtensions;
      };
  code = writeShellScriptBin "code" ''
    ${updateSettingsCmd}/bin/vscodeNixUpdate-settings
    ${updateLaunchCmd}/bin/vscodeNixUpdate-launch
    ${updateKeybindingsCmd}/bin/vscodeNixUpdate-keybindings
    ${vscodeWithConfiguration}/bin/code --wait "$@"
    echo 'running vscodeExts2nix to update ${mutableExtensionsFilePath}...'
    ${vscodeExts2nix}/bin/vscodeExts2nix > ${mutableExtensionsFilePath}
  '';
in
buildEnv {
  name = "vscodeEnv";

  paths = [
    code
    vscodeExts2nix
    updateSettingsCmd
    updateLaunchCmd
    updateKeybindingsCmd
  ];
}
