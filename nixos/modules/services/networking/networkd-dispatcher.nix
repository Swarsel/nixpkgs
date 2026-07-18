{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let

  cfg = config.services.networkd-dispatcher;

in
{

  options = {
    services.networkd-dispatcher = {

      enable = mkEnableOption ''
        Networkd-dispatcher service for systemd-networkd connection status
        change. See [upstream instructions](https://gitlab.com/craftyguy/networkd-dispatcher)
        for usage
      '';

      extraArgs = mkOption {
        apply = escapeShellArgs;
        default = [ ];

        description = ''
          Extra arguments to pass to the networkd-dispatcher command.
        '';

        type = types.listOf types.str;
      };

      rules = mkOption {
        default = { };

        description = ''
          Declarative configuration of networkd-dispatcher rules. See
          [upstream instructions](https://gitlab.com/craftyguy/networkd-dispatcher)
          for an introduction and example scripts.
        '';

        example = lib.literalExpression ''
          { "restart-tor" = {
              onState = ["routable" "off"];
              script = '''
                #!''${pkgs.runtimeShell}
                if [[ $IFACE == "wlan0" && $AdministrativeState == "configured" ]]; then
                  echo "Restarting Tor ..."
                  systemctl restart tor
                fi
                exit 0
              ''';
            };
          };
        '';

        type = types.attrsOf (
          types.submodule {
            options = {
              onState = mkOption {
                default = null;

                description = ''
                  List of names of the systemd-networkd operational states which
                  should trigger the script. See {manpage}`networkctl(1)`
                  for a description of the specific state type.
                '';

                type = types.listOf (
                  types.enum [
                    "routable"
                    "dormant"
                    "no-carrier"
                    "off"
                    "carrier"
                    "degraded"
                    "configuring"
                    "configured"
                    "enslaved"
                  ]
                );
              };

              script = mkOption {
                description = ''
                  Shell commands executed on specified operational states.
                '';

                type = types.lines;
              };
            };
          }
        );
      };

    };
  };

  config = mkIf cfg.enable {

    services.networkd-dispatcher.extraArgs =
      let
        scriptDir = pkgs.runCommand "networkd-dispatcher-script-dir" { } (
          ''
            mkdir $out
          ''
          + (lib.concatStrings (
            lib.mapAttrsToList (
              name: cfg:
              (lib.concatStrings (
                map (state: ''
                  mkdir -p $out/${state}.d
                  ln -s ${
                    lib.getExe (
                      pkgs.writeShellApplication {
                        inherit name;
                        text = cfg.script;
                      }
                    )
                  } $out/${state}.d/${name}
                '') cfg.onState
              ))
            ) cfg.rules
          ))
        );
      in
      [
        "--verbose"
        "--script-dir"
        "${scriptDir}"
      ];

    systemd = {
      packages = [ pkgs.networkd-dispatcher ];

      services.networkd-dispatcher = {
        environment.networkd_dispatcher_args = cfg.extraArgs;
        wantedBy = [ "multi-user.target" ];
      };
    };

    warnings = mkIf (!config.systemd.network.enable) [
      "services.networkd-dispatcher will not execute any scripts unless networkd is enabled, either via `systemd.network.enable` or via `networking.useNetworkd`."
    ];

  };
}
