{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.duckling;
in
{
  options = {
    services.duckling = {
      enable = lib.mkEnableOption "duckling";

      port = lib.mkOption {
        default = 8080;

        description = ''
          Port on which duckling will run.
        '';

        type = lib.types.port;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.duckling = {
      after = [ "network.target" ];
      description = "Duckling server service";

      environment = {
        PORT = toString cfg.port;
      };

      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${pkgs.haskellPackages.duckling}/bin/duckling-example-exe --no-access-log --no-error-log";
        Restart = "always";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
