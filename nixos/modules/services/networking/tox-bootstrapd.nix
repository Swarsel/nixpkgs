{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  WorkingDirectory = "/var/lib/tox-bootstrapd";
  PIDFile = "${WorkingDirectory}/pid";

  pkg = pkgs.libtoxcore;
  cfg = config.services.toxBootstrapd;
  cfgFile = builtins.toFile "tox-bootstrapd.conf" ''
    port = ${toString cfg.port}
    keys_file_path = "${WorkingDirectory}/keys"
    pid_file_path = "${PIDFile}"
    ${cfg.extraConfig}
  '';
in
{
  options = {
    services.toxBootstrapd = {
      enable = mkOption {
        default = false;

        description = ''
          Whether to enable the Tox DHT bootstrap daemon.
        '';

        type = types.bool;
      };

      extraConfig = mkOption {
        default = "";

        description = ''
          Configuration for bootstrap daemon.
          See <https://github.com/irungentoo/toxcore/blob/master/other/bootstrap_daemon/tox-bootstrapd.conf>
          and <https://wiki.tox.chat/users/nodes>.
        '';

        type = types.lines;
      };

      keysFile = mkOption {
        default = "${WorkingDirectory}/keys";
        description = "Node key file.";
        type = types.str;
      };

      port = mkOption {
        default = 33445;
        description = "Listening port (UDP).";
        type = types.port;
      };
    };

  };

  config = mkIf config.services.toxBootstrapd.enable {

    systemd.services.tox-bootstrapd = {
      after = [ "network.target" ];
      description = "Tox DHT bootstrap daemon";

      serviceConfig = {
        inherit PIDFile WorkingDirectory;
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
        DynamicUser = true;
        ExecStart = "${pkg}/bin/tox-bootstrapd --config=${cfgFile}";
        StateDirectory = "tox-bootstrapd";
        Type = "forking";
      };

      wantedBy = [ "multi-user.target" ];
    };

  };
}
