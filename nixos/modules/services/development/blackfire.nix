{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.blackfire-agent;

  agentConfigFile = lib.generators.toINI { } {
    blackfire = cfg.settings;
  };

  agentSock = "blackfire/agent.sock";
in
{
  options = {
    services.blackfire-agent = {
      enable = lib.mkEnableOption "Blackfire profiler agent";

      settings = lib.mkOption {
        description = ''
          See <https://blackfire.io/docs/up-and-running/configuration/agent>
        '';

        type = lib.types.submodule {
          options = {
            server-id = lib.mkOption {
              description = ''
                Sets the server id used to authenticate with Blackfire

                You can find your personal server-id at <https://blackfire.io/my/settings/credentials>
              '';

              type = lib.types.str;
            };

            server-token = lib.mkOption {
              description = ''
                Sets the server token used to authenticate with Blackfire

                You can find your personal server-token at <https://blackfire.io/my/settings/credentials>
              '';

              type = lib.types.str;
            };
          };

          freeformType = with lib.types; attrsOf str;
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."blackfire/agent".text = agentConfigFile;
    services.blackfire-agent.settings.socket = "unix:///run/${agentSock}";

    systemd.packages = [
      pkgs.blackfire
    ];
  };

  meta = {
    doc = ./blackfire.md;
    maintainers = pkgs.blackfire.meta.maintainers;
  };
}
