{
  lib,
  callPackage,
  stdenvNoCC,
  writeShellScript,
}:
let
  root = ./.;
  updateScript = ./update.py;

  mkYaziPlugin = lib.extendMkDerivation {
    constructDrv = stdenvNoCC.mkDerivation;

    extendDrvArgs =
      finalAttrs:
      {
        pname,
        src,
        installPhase ? null,
        meta ? { },
        ...
      }@args:
      let
        # Extract the plugin name from pname (removing .yazi suffix if present)
        pluginName = lib.removeSuffix ".yazi" pname;
      in
      {
        installPhase =
          if installPhase != null then
            installPhase
          else if (src ? owner && src.owner == "yazi-rs") then
            # NOTE: License is a relative symbolic link
            # We remove the link and copy the true license
            ''
              runHook preInstall

              cp -r ${pname} $out
              rm $out/LICENSE
              cp LICENSE $out

              runHook postInstall
            ''
          else
            # Normal plugins don't require special installation other than to copy their contents.
            ''
              runHook preInstall

              cp -r . $out

              runHook postInstall
            '';

        passthru = (args.passthru or { }) // {
          updateScript = {
            command = writeShellScript "update-${pluginName}" ''
              export PLUGIN_NAME="${pluginName}"
              export PLUGIN_PNAME="${pname}"
              exec ${updateScript}
            '';

            supportedFeatures = [ "commit" ];
          };
        };

        meta = meta // {
          description = meta.description or "";

          homepage =
            if (src ? owner && src.owner == "yazi-rs") then
              "https://github.com/yazi-rs/plugins/tree/main/${pname}"
            else
              meta.homepage or null;

          platforms = meta.platforms or lib.platforms.all;
        };
      };
  };

  call = name: callPackage (root + "/${name}") { inherit mkYaziPlugin; };
in
lib.pipe root [
  builtins.readDir
  (lib.filterAttrs (_: type: type == "directory"))
  (builtins.mapAttrs (name: _: call name))
]
// {
  inherit mkYaziPlugin;
}
