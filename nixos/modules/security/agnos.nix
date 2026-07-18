{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.security.agnos;
  format = pkgs.formats.toml { };
  name = "agnos";
  stateDir = "/var/lib/${name}";

  accountType =
    let
      inherit (lib) types mkOption;
    in
    types.submodule {
      options = {
        certificates = mkOption {
          description = ''
            Certificates for agnos to issue or renew.
          '';

          type = types.listOf certificateType;
        };

        email = mkOption {
          description = ''
            Email associated with this account.
          '';

          type = types.str;
        };

        private_key_path = mkOption {
          description = ''
            Path of the PEM-encoded private key for this account.
            Currently, only RSA keys are supported.

            If this path does not exist, then the behavior depends on `generateKeys.enable`.
            When this option is `true`,
            the key will be automatically generated and saved to this path.
            When it is `false`, agnos will fail.

            If a relative path is specified,
            the key will be looked up (or generated and saved to) under `${stateDir}`.
          '';

          type = types.str;
        };
      };

      freeformType = types.attrsOf format.type;
    };

  certificateType =
    let
      inherit (lib) types literalExpression mkOption;
    in
    types.submodule {
      options = {
        domains = mkOption {
          description = ''
            Domains the certificate represents
          '';

          example = literalExpression ''["a.example.com", "b.example.com", "*b.example.com"]'';
          type = types.listOf types.str;
        };

        fullchain_output_file = mkOption {
          description = ''
            Output path for the full chain including the acquired certificate.
            If a relative path is specified, the file will be created in `${stateDir}`.
          '';

          type = types.str;
        };

        key_output_file = mkOption {
          description = ''
            Output path for the certificate private key.
            If a relative path is specified, the file will be created in `${stateDir}`.
          '';

          type = types.str;
        };
      };

      freeformType = types.attrsOf format.type;
    };
in
{
  options.security.agnos =
    let
      inherit (lib) types mkEnableOption mkOption;
    in
    {
      enable = mkEnableOption name;

      generateKeys = {
        enable = mkOption {
          default = false;

          description = ''
            Enable automatic generation of account keys.

            When this is `true`, a key will be generated for each account where
            the file referred to by the `private_key` path does not exist yet.

            Currently, only RSA keys can be generated.
          '';

          type = types.bool;
        };

        keySize = mkOption {
          default = 4096;

          description = ''
            Key size in bits to use when generating new keys.
          '';

          type = types.int;
        };
      };

      group = mkOption {
        default = name;

        description = ''
          Group to run Agnos as. The acquired certificates will be owned by this group.
        '';

        type = types.str;
      };

      persistent = mkOption {
        default = true;

        description = ''
          When `true`, use a persistent systemd timer.
        '';

        type = types.bool;
      };

      server = mkOption {
        default = null;

        description = ''
          ACME Directory Resource URI. Defaults to Let's Encrypt's production endpoint,
          `https://acme-v02.api.letsencrypt.org/directory`, if unset.
        '';

        type = types.nullOr types.str;
      };

      serverCa = mkOption {
        default = null;

        description = ''
          The root certificate (in PEM format) of the ACME server's HTTPS interface.
        '';

        type = types.nullOr types.path;
      };

      settings = mkOption {
        description = "Settings";

        type = types.submodule {
          options = {
            accounts = mkOption {
              description = ''
                A list of ACME accounts.
                Each account is associated with an email address
                and can be used to obtain an arbitrary amount of certificate
                (subject to provider's rate limits,
                see e.g. [Let's Encrypt Rate Limits](https://letsencrypt.org/docs/rate-limits/)).
              '';

              type = types.listOf accountType;
            };

            dns_listen_addr = mkOption {
              default = "0.0.0.0:53";

              description = ''
                Address for agnos to listen on.
                Note that this needs to be reachable by the outside world,
                and 53 is required in most situations
                since `NS` records do not allow specifying the port.
              '';

              type = types.str;
            };
          };

          freeformType = types.attrsOf format.type;
        };
      };

      startAt = mkOption {
        default = "daily";

        description = ''
          How often or when to run agnos.

          The format is described in
          {manpage}`systemd.time(7)`.
        '';

        example = "02:00";
        type = types.either types.str (types.listOf types.str);
      };

      temporarilyOpenFirewall = mkOption {
        default = false;

        description = ''
          When `true`, will open the port specified in `settings.dns_listen_addr`
          before running the agnos service, and close it when agnos finishes running.
        '';

        type = types.bool;
      };

      user = mkOption {
        default = name;

        description = ''
          User to run Agnos as. The acquired certificates will be owned by this user.
        '';

        type = types.str;
      };
    };

  config =
    let
      configFile = format.generate "agnos.toml" cfg.settings;
      port = lib.toInt (lib.last (builtins.split ":" cfg.settings.dns_listen_addr));

      useNftables = config.networking.nftables.enable;

      # nftables implementation for temporarilyOpenFirewall
      nftablesSetup = pkgs.writeShellScript "agnos-fw-setup" ''
        ${lib.getExe pkgs.nftables} add element inet nixos-fw temp-ports "{ tcp . ${toString port} }"
        ${lib.getExe pkgs.nftables} add element inet nixos-fw temp-ports "{ udp . ${toString port} }"
      '';
      nftablesTeardown = pkgs.writeShellScript "agnos-fw-teardown" ''
        ${lib.getExe pkgs.nftables} delete element inet nixos-fw temp-ports "{ tcp . ${toString port} }"
        ${lib.getExe pkgs.nftables} delete element inet nixos-fw temp-ports "{ udp . ${toString port} }"
      '';

      # iptables implementation for temporarilyOpenFirewall
      helpers = ''
        function ip46tables() {
          ${lib.getExe' pkgs.iptables "iptables"} -w "$@"
          ${lib.getExe' pkgs.iptables "ip6tables"} -w "$@"
        }
      '';
      fwFilter = ''--dport ${toString port} -j ACCEPT -m comment --comment "agnos"'';
      iptablesSetup = pkgs.writeShellScript "agnos-fw-setup" ''
        ${helpers}
        ip46tables -I INPUT 1 -p tcp ${fwFilter}
        ip46tables -I INPUT 1 -p udp ${fwFilter}
      '';
      iptablesTeardown = pkgs.writeShellScript "agnos-fw-setup" ''
        ${helpers}
        ip46tables -D INPUT -p tcp ${fwFilter}
        ip46tables -D INPUT -p udp ${fwFilter}
      '';
    in
    lib.mkIf cfg.enable {
      assertions = [
        {
          assertion = !cfg.temporarilyOpenFirewall || config.networking.firewall.enable;
          message = "temporarilyOpenFirewall is only useful when firewall is enabled";
        }
      ];

      systemd.services.agnos = {
        after = [
          "firewall.target"
          "network-online.target"
          "nftables.service"
        ];

        serviceConfig = {
          AmbientCapabilities = lib.mkIf (port < 1024) [ "CAP_NET_BIND_SERVICE" ];
          # Allow binding privileged ports if necessary
          CapabilityBoundingSet = lib.mkIf (port < 1024) [ "CAP_NET_BIND_SERVICE" ];

          ExecStart = ''
            ${pkgs.agnos}/bin/agnos \
              ${if cfg.server != null then "--acme-url=${cfg.server}" else "--no-staging"} \
              ${lib.optionalString (cfg.serverCa != null) "--acme-serv-ca=${cfg.serverCa}"} \
              ${configFile}
          '';

          ExecStartPre =
            lib.optional cfg.generateKeys.enable ''
              ${pkgs.agnos}/bin/agnos-generate-accounts-keys \
                --no-confirm \
                --key-size ${toString cfg.generateKeys.keySize} \
                ${configFile}
            ''
            ++ lib.optional cfg.temporarilyOpenFirewall (
              "+" + (if useNftables then nftablesSetup else iptablesSetup)
            );

          ExecStopPost = lib.optional cfg.temporarilyOpenFirewall (
            "+" + (if useNftables then nftablesTeardown else iptablesTeardown)
          );

          Group = cfg.group;
          StateDirectory = name;
          StateDirectoryMode = "0750";
          Type = "oneshot";
          User = cfg.user;
          WorkingDirectory = "${stateDir}";
        };

        wants = [ "network-online.target" ];
      };

      systemd.timers.agnos = {
        timerConfig = {
          OnCalendar = cfg.startAt;
          Persistent = cfg.persistent;
          Unit = "agnos.service";
        };

        wantedBy = [ "timers.target" ];
      };

      users.groups = lib.mkIf (cfg.group == name) {
        ${cfg.group} = { };
      };

      users.users = lib.mkIf (cfg.user == name) {
        ${cfg.user} = {
          description = "Agnos service user";
          group = cfg.group;
          isSystemUser = true;
        };
      };
    };
}
