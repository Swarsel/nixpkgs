# Source: https://git.helsinki.tools/helsinki-systems/wp4nix/-/blob/master/default.nix
# Licensed under: MIT
# Slightly modified

{
  lib,
  callPackage,
  ncVersion,
  newScope,
  nextcloud-notify_push,
  pkgs,
  apps ? lib.importJSON (./. + "/${ncVersion}.json"), # Support out-of-tree overrides
}:

let
  packages =
    self:
    let
      generatedJson = {
        inherit apps;
      };
      appBaseDefs = builtins.fromJSON (builtins.readFile ./nextcloud-apps.json);

    in
    {
      # Create a derivation from the official Nextcloud apps.
      # This takes the data generated from the go tool.
      mkNextcloudDerivation =
        { data, pname }:
        pkgs.fetchNextcloudApp {
          inherit (data)
            url
            hash
            description
            homepage
            ;

          appName = pname;
          appVersion = data.version;
          license = appBaseDefs.${pname};
          teams = [ lib.teams.nextcloud ];
        };

    }
    // lib.mapAttrs (
      type: pkgs:
      lib.makeExtensible (
        _:
        lib.mapAttrs (
          pname: data:
          self.mkNextcloudDerivation {
            inherit pname data;
          }
        ) pkgs
        // {
          notify_push = nextcloud-notify_push.app;
        }
      )
    ) generatedJson;

in
(lib.makeExtensible (_: (lib.makeScope newScope packages))).extend (
  import ./thirdparty.nix { inherit ncVersion; }
)
