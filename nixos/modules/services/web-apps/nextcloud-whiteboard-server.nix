{
  config,
  lib,
  pkgs,
  ...
}:

let

  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    types
    literalExpression
    ;
  cfg = config.services.nextcloud-whiteboard-server;

in
{
  options.services.nextcloud-whiteboard-server = {

    enable = mkEnableOption "Nextcloud backend server for the Whiteboard app";

    secrets = lib.mkOption {
      default = [ ];

      description = ''
        A list of files containing the various secrets. Should be in the
        format expected by systemd's `EnvironmentFile` directory.
      '';

      type = with types; listOf str;
    };

    settings = mkOption {
      default = { };

      description = ''
        Settings to configure backend server. Especially the Nextcloud host
        url has to be set. The required environment variable `JWT_SECRET_KEY`
        should be set via the secrets option.
      '';

      example = literalExpression ''
        {
          NEXTCLOUD_URL = "https://nextcloud.example.org";
        }
      '';

      type = types.attrsOf types.str;
    };

  };

  config = mkIf cfg.enable {

    systemd.services.nextcloud-whiteboard-server = {
      after = [ "network-online.target" ];
      description = "Nextcloud backend server for the Whiteboard app";
      environment = cfg.settings;

      serviceConfig = {
        DynamicUser = true;
        EnvironmentFile = [ cfg.secrets ];
        ExecStart = "${lib.getExe pkgs.nextcloud-whiteboard-server}";
        StateDirectory = "whiteboard";
        WorkingDirectory = "%S/whiteboard";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };

  };

  meta.maintainers = with lib.maintainers; [ onny ];

}
