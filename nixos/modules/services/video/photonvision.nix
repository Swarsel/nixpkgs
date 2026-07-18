{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.photonvision;
in
{
  options = {
    services.photonvision = {
      enable = lib.mkEnableOption "PhotonVision";
      package = lib.mkPackageOption pkgs "photonvision" { };

      openFirewall = lib.mkOption {
        default = false;

        description = ''
          Whether to open the required ports in the firewall.
        '';

        type = lib.types.bool;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPortRanges = [
        {
          from = 1180;
          to = 1190;
        }
      ];

      allowedTCPPorts = [ 5800 ];
    };

    systemd.services.photonvision = {
      after = [ "network.target" ];
      description = "PhotonVision, the free, fast, and easy-to-use computer vision solution for the FIRST Robotics Competition";

      serviceConfig = {
        BindPaths = [
          # mount the configuration and logs directories to the host
          "/var/lib/photonvision:/photonvision_config"
          "/var/log/photonvision:/photonvision_config/logs"
        ];

        BindReadOnlyPaths = [
          # mount the nix store read-only
          "/nix/store"

          # the JRE reads the user.home property from /etc/passwd
          "/etc/passwd"
        ];

        ExecStart = lib.getExe cfg.package;
        LogsDirectory = "photonvision";
        # for PhotonVision's dynamic libraries, which it writes to /tmp
        PrivateTmp = true;
        RootDirectory = "/run/photonvision";
        # ephemeral root directory
        RuntimeDirectory = "photonvision";
        # setup persistent state and logs directories
        StateDirectory = "photonvision";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
