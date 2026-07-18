{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let

  cfg = config.services.openvpn;

  makeOpenVPNJob =
    cfg: name:
    let

      path = makeBinPath (getAttr "openvpn-${name}" config.systemd.services).path;

      upScript = ''
        export PATH=${path}

        # For convenience in client scripts, extract the remote domain
        # name and name server.
        for var in ''${!foreign_option_*}; do
          x=(''${!var})
          if [ "''${x[0]}" = dhcp-option ]; then
            if [ "''${x[1]}" = DOMAIN ]; then domain="''${x[2]}"
            elif [ "''${x[1]}" = DNS ]; then nameserver="''${x[2]}"
            fi
          fi
        done

        ${cfg.up}
        ${optionalString cfg.updateResolvConf "${pkgs.update-resolv-conf}/libexec/openvpn/update-resolv-conf"}
      '';

      downScript = ''
        export PATH=${path}
        ${optionalString cfg.updateResolvConf "${pkgs.update-resolv-conf}/libexec/openvpn/update-resolv-conf"}
        ${cfg.down}
      '';

      configFile = pkgs.writeText "openvpn-config-${name}" ''
        errors-to-stderr
        ${optionalString (cfg.up != "" || cfg.down != "" || cfg.updateResolvConf) "script-security 2"}
        ${cfg.config}
        ${optionalString (
          cfg.up != "" || cfg.updateResolvConf
        ) "up ${pkgs.writeShellScript "openvpn-${name}-up" upScript}"}
        ${optionalString (
          cfg.down != "" || cfg.updateResolvConf
        ) "down ${pkgs.writeShellScript "openvpn-${name}-down" downScript}"}
        ${optionalString (cfg.authUserPass != null) (
          if isAttrs cfg.authUserPass then
            "auth-user-pass ${pkgs.writeText "openvpn-credentials-${name}" ''
              ${cfg.authUserPass.username}
              ${cfg.authUserPass.password}
            ''}"
          else
            "auth-user-pass ${cfg.authUserPass}"
        )}
      '';

    in
    {
      after = [ "network.target" ];
      description = "OpenVPN instance ‘${name}’";

      path = [
        pkgs.iptables
        pkgs.iproute2
        pkgs.net-tools
      ];

      serviceConfig.ExecStart = "@${config.services.openvpn.package}/sbin/openvpn openvpn --suppress-timestamps --config ${configFile}";
      serviceConfig.Restart = "always";
      serviceConfig.Type = "notify";
      wantedBy = optional cfg.autoStart "multi-user.target";
    };

  restartService = optionalAttrs cfg.restartAfterSleep {
    openvpn-restart = {
      description = "Restart system OpenVPN connections when returning from sleep";

      script =
        let
          unitNames = map (n: "openvpn-${n}.service") (builtins.attrNames cfg.servers);
        in
        "systemctl try-restart ${lib.escapeShellArgs unitNames}";

      wantedBy = [ "sleep.target" ];
    };
  };

in

{
  imports = [
    (mkRemovedOptionModule [ "services" "openvpn" "enable" ] "")
  ];

  ###### interface

  options = {
    services.openvpn.package = lib.mkPackageOption pkgs "openvpn" { };

    services.openvpn.restartAfterSleep = mkOption {
      default = true;
      description = "Whether OpenVPN client should be restarted after sleep.";
      type = types.bool;
    };

    services.openvpn.servers = mkOption {
      default = { };

      description = ''
        Each attribute of this option defines a systemd service that
        runs an OpenVPN instance.  These can be OpenVPN servers or
        clients.  The name of each systemd service is
        `openvpn-«name».service`,
        where «name» is the corresponding
        attribute name.
      '';

      example = literalExpression ''
        {
          server = {
            config = '''
              # Simplest server configuration: https://community.openvpn.net/openvpn/wiki/StaticKeyMiniHowto
              # server :
              dev tun
              ifconfig 10.8.0.1 10.8.0.2
              secret /root/static.key
            ''';
            up = "ip route add ...";
            down = "ip route del ...";
          };

          client = {
            config = '''
              client
              remote vpn.example.org
              dev tun
              proto tcp-client
              port 8080
              ca /root/.vpn/ca.crt
              cert /root/.vpn/alice.crt
              key /root/.vpn/alice.key
            ''';
            up = "echo nameserver $nameserver | ''${pkgs.openresolv}/sbin/resolvconf -m 0 -a $dev";
            down = "''${pkgs.openresolv}/sbin/resolvconf -d $dev";
          };
        }
      '';

      type =
        with types;
        attrsOf (submodule {

          options = {

            config = mkOption {
              description = ''
                Configuration of this OpenVPN instance.  See
                {manpage}`openvpn(8)`
                for details.

                To import an external config file, use the following definition:
                `config = "config /path/to/config.ovpn"`
              '';

              type = types.lines;
            };

            authUserPass = mkOption {
              default = null;

              description = ''
                This option can be used to store the username / password credentials
                with the "auth-user-pass" authentication method.

                You can either provide an attribute set of `username` and `password`,
                or the path to a file containing the credentials on two lines.

                WARNING: If you use an attribute set, this option will put the credentials WORLD-READABLE into the Nix store!
              '';

              type = types.nullOr (
                types.oneOf [
                  types.singleLineStr
                  (types.submodule {
                    options = {
                      password = mkOption {
                        description = "The password to store inside the credentials file.";
                        type = types.str;
                      };

                      username = mkOption {
                        description = "The username to store inside the credentials file.";
                        type = types.str;
                      };
                    };
                  })
                ]
              );
            };

            autoStart = mkOption {
              default = true;
              description = "Whether this OpenVPN instance should be started automatically.";
              type = types.bool;
            };

            down = mkOption {
              default = "";

              description = ''
                Shell commands executed when the instance is shutting down.
              '';

              type = types.lines;
            };

            up = mkOption {
              default = "";

              description = ''
                Shell commands executed when the instance is starting.
              '';

              type = types.lines;
            };

            updateResolvConf = mkOption {
              default = false;

              description = ''
                Use the script from the update-resolv-conf package to automatically
                update resolv.conf with the DNS information provided by openvpn. The
                script will be run after the "up" commands and before the "down" commands.
              '';

              type = types.bool;
            };
          };

        });

    };

  };

  ###### implementation

  config = mkIf (cfg.servers != { }) {

    boot.kernelModules = [ "tun" ];
    environment.systemPackages = [ cfg.package ];

    systemd.services =
      (listToAttrs (
        mapAttrsToList (
          name: value: nameValuePair "openvpn-${name}" (makeOpenVPNJob value name)
        ) cfg.servers
      ))
      // restartService;

  };

}
