{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.pixiecore;
in
{
  options = {
    services.pixiecore = {
      enable = mkEnableOption "Pixiecore";

      apiServer = mkOption {
        description = "URI to connect to the API. Ignored unless mode is set to 'api'";
        example = "http://localhost:8080";
        type = types.str;
      };

      cmdLine = mkOption {
        default = "";
        description = "Kernel commandline arguments. Ignored unless mode is set to 'boot'";
        type = types.str;
      };

      debug = mkOption {
        default = false;
        description = "Log more things that aren't directly related to booting a recognized client";
        type = types.bool;
      };

      dhcpNoBind = mkOption {
        default = false;
        description = "Handle DHCP traffic without binding to the DHCP server port";
        type = types.bool;
      };

      extraArguments = mkOption {
        default = [ ];
        description = "Additional command line arguments to pass to Pixiecore";
        type = types.listOf types.str;
      };

      initrd = mkOption {
        default = "";
        description = "Initrd path. Ignored unless mode is set to 'boot'";
        type = types.str or types.path;
      };

      kernel = mkOption {
        default = "";
        description = "Kernel path. Ignored unless mode is set to 'boot'";
        type = types.str or types.path;
      };

      listen = mkOption {
        default = "0.0.0.0";
        description = "IPv4 address to listen on";
        type = types.str;
      };

      mode = mkOption {
        default = "boot";
        description = "Which mode to use";

        type = types.enum [
          "api"
          "boot"
          "quick"
        ];
      };

      openFirewall = mkOption {
        default = false;

        description = ''
          Open ports (67, 69, 4011 UDP and 'port', 'statusPort' TCP) in the firewall for Pixiecore.
        '';

        type = types.bool;
      };

      port = mkOption {
        default = 80;
        description = "Port to listen on for HTTP";
        type = types.port;
      };

      quick = mkOption {
        default = "xyz";
        description = "Which quick option to use";

        type = types.enum [
          "arch"
          "centos"
          "coreos"
          "debian"
          "fedora"
          "ubuntu"
          "xyz"
        ];
      };

      statusPort = mkOption {
        default = 80;
        description = "HTTP port for status information (can be the same as --port)";
        type = types.port;
      };
    };
  };

  config = mkIf cfg.enable {
    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [
        cfg.port
        cfg.statusPort
      ];

      allowedUDPPorts = [
        67
        69
        4011
      ];
    };

    systemd.services.pixiecore = {
      after = [ "network.target" ];
      description = "Pixiecore server";

      serviceConfig = {
        AmbientCapabilities = [ "cap_net_bind_service" ] ++ optional cfg.dhcpNoBind "cap_net_raw";

        ExecStart =
          let
            argString =
              if cfg.mode == "boot" then
                [
                  "boot"
                  cfg.kernel
                ]
                ++ optional (cfg.initrd != "") cfg.initrd
                ++ optionals (cfg.cmdLine != "") [
                  "--cmdline"
                  cfg.cmdLine
                ]
              else if cfg.mode == "quick" then
                [
                  "quick"
                  cfg.quick
                ]
              else
                [
                  "api"
                  cfg.apiServer
                ];
          in
          ''
            ${pkgs.pixiecore}/bin/pixiecore \
              ${lib.escapeShellArgs argString} \
              ${optionalString cfg.debug "--debug"} \
              ${optionalString cfg.dhcpNoBind "--dhcp-no-bind"} \
              --listen-addr ${lib.escapeShellArg cfg.listen} \
              --port ${toString cfg.port} \
              --status-port ${toString cfg.statusPort} \
              ${escapeShellArgs cfg.extraArguments}
          '';

        Restart = "always";
        User = "pixiecore";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network.target" ];
    };

    users.groups.pixiecore = { };

    users.users.pixiecore = {
      description = "Pixiecore daemon user";
      group = "pixiecore";
      isSystemUser = true;
    };
  };

  meta.maintainers = with maintainers; [ bbigras ];
}
