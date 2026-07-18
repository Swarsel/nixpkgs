{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.dsnet;
  settingsFormat = pkgs.formats.json { };
  patchFile = settingsFormat.generate "dsnet-patch.json" cfg.settings;
in
{
  options.services.dsnet = {
    enable = lib.mkEnableOption "dsnet, a centralised Wireguard VPN manager";
    package = lib.mkPackageOption pkgs "dsnet" { };

    settings = lib.mkOption {
      default = { };

      description = ''
        The settings to use for dsnet. This will be converted to a JSON
        object that will be passed to dsnet as a patch, using the patch
        command when the service is started. See the dsnet documentation for
        more information on the additional options.

        Note that the resulting /etc/dsnetconfg.json is more of a database
        than it is a configuration file. It is therefore recommended that
        system specific values are configured here, rather than the full
        configuration including peers.

        Peers may be managed via the dsnet add/remove commands, negating the
        need to manage key material and cumbersom configuration with nix. If
        you want peer configuration in nix, you may as well use the regular
        wireguard module.
      '';

      example = {
        DNS = "8.8.8.8";
        ExternalHostname = "vpn.example.com";
        ExternalIP = "127.0.0.1";
        ExternalIP6 = "";
        IP = "10.3.148.1";
        IP6 = "";
        ListenPort = 51820;
        Network = "10.3.148.0/22";
        Network6 = "";
        Networks = [ "0.0.0.0/0" ];
      };

      type = lib.types.submodule {

        options = {
          ExternalHostname = lib.mkOption {
            default = null;

            description = ''
              The hostname that clients should use to connect to this server.
              This is used to generate the client configuration files.

              This is preferred over ExternalIP, as it allows for IPv4 and
              IPv6, as well as enabling the ability tp change IP.
            '';

            example = "vpn.example.com";
            type = lib.types.nullOr lib.types.str;
          };

          ExternalIP = lib.mkOption {
            default = null;

            description = ''
              The external IP address of the server. This is used to generate
              the client configuration files for when an ExternalHostname is not set.

              Leaving this empty will cause dsnet to use the IP address of
              what looks like the WAN interface.
            '';

            example = "192.0.2.1";
            type = lib.types.nullOr lib.types.str;
          };

          ExternalIP6 = lib.mkOption {
            default = null;

            description = ''
              The external IPv6 address of the server. This is used to generate
              the client configuration files for when an ExternalHostname is
              not set. Used in preference to ExternalIP.

              Leaving this empty will cause dsnet to use the IP address of
              what looks like the WAN interface.
            '';

            example = "2001:db8::1";
            type = lib.types.nullOr lib.types.str;
          };

          IP = lib.mkOption {
            default = null;

            description = ''
              The IPv4 address that the server will use on the network.
              Leave this empty to let dsnet choose an address.
            '';

            example = "172.18.0.1";
            type = lib.types.nullOr lib.types.str;
          };

          IP6 = lib.mkOption {
            default = null;

            description = ''
              The IPv6 address that the server will use on the network
              Leave this empty to let dsnet choose an address.
            '';

            example = "2001:db8::1";
            type = lib.types.nullOr lib.types.str;
          };

          Network = lib.mkOption {
            default = null;

            description = ''
              The IPv4 network that the server will use to allocate IPs on the network.
              Leave this empty to let dsnet choose a network.
            '';

            example = "172.18.0.0/24";
            type = lib.types.nullOr lib.types.str;
          };

          Network6 = lib.mkOption {
            default = null;

            description = ''
              The IPv6 network that the server will use to allocate IPs on the
              network.
              Leave this empty to let dsnet choose a network.
            '';

            example = "2001:db8::1/64";
            type = lib.types.nullOr lib.types.str;
          };

          Networks = lib.mkOption {
            default = null;

            description = ''
              The CIDR networks that should route through this server. Clients
              will be configured to route traffic for these networks through
              the server peer.
            '';

            example = [
              "0.0.0.0/0"
              "192.168.0.0/24"
            ];

            type = lib.types.nullOr (lib.types.listOf lib.types.str);
          };
        };

        freeformType = settingsFormat.type;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    systemd.services.dsnet = {
      after = [ "network-online.target" ];
      description = "dsnet VPN Management";

      preStart = ''
        test ! -f /etc/dsnetconfig.json && ${lib.getExe cfg.package} init
        ${lib.getExe cfg.package} patch < ${patchFile}
      '';

      reload = ''
        ${lib.getExe cfg.package} patch < ${patchFile}
        ${lib.getExe cfg.package} sync < ${patchFile}
      '';

      # reload _instead_ of restarting on change
      reloadIfChanged = true;

      serviceConfig = {
        ExecStart = "${lib.getExe cfg.package} up";
        ExecStop = "${lib.getExe cfg.package} down";
        # consider the service to be active after process exits, so it can be
        # reloaded
        RemainAfterExit = true;
        Type = "oneshot";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };
}
