{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.crab-hole;

  settingsFormat = pkgs.formats.toml { };

  checkConfig =
    file:
    pkgs.runCommand "check-config"
      {
        nativeBuildInputs = [
          cfg.package
          pkgs.cacert
          pkgs.dig
        ];
      }
      ''
        ln -s ${file} $out

        ln -s ${file} ./config.toml
        export CRAB_HOLE_DIR=$(pwd)

        ${lib.getExe cfg.package} validate-config
      '';
in
{
  options = {
    services.crab-hole = {
      enable = lib.mkEnableOption "Crab-hole Service";
      package = lib.mkPackageOption pkgs "crab-hole" { };

      configFile = lib.mkOption {
        description = ''
          The config file of crab-hole.

          If files are added via url, make sure the service has access to them.
          Setting this option will override any configuration applied by the settings option.
        '';

        type = lib.types.path;
      };

      settings = lib.mkOption {
        description = "Crab-holes config. See big example <https://github.com/LuckyTurtleDev/crab-hole/blob/main/example-config.toml>";

        example = {
          api = {
            admin_key = "1234";
            listen = "127.0.0.1";
            port = 8080;
            show_doc = true;
          };

          blocklist = {
            allow_list = [
              "file:///allowed.txt"
            ];

            include_subdomains = true;

            lists = [
              "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn/hosts"
              "https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt"
              "file:///blocked.txt"
            ];
          };

          downstream = [
            {
              listen = "localhost";
              port = 8080;
              protocol = "udp";
            }
            {
              certificate = "dns.example.com.crt";
              dns_hostname = "dns.example.com";
              key = "dns.example.com.key";
              listen = "[::]";
              port = 8055;
              protocol = "https";
              timeout_ms = 3000;
            }
          ];

          upstream = {
            options = {
              validate = false;
            };

            name_servers = [
              {
                protocol = "tls";
                socket_addr = "[2606:4700:4700::1111]:853";
                tls_dns_name = "1dot1dot1dot1.cloudflare-dns.com";
                trust_nx_responses = false;
              }
              {
                protocol = "tls";
                socket_addr = "1.1.1.1:853";
                tls_dns_name = "1dot1dot1dot1.cloudflare-dns.com";
                trust_nx_responses = false;
              }
            ];
          };
        };

        type = lib.types.submodule {
          options = {
            blocklist =
              let
                listOption =
                  name:
                  lib.mkOption {
                    apply = map (v: if builtins.isPath v then "file://${v}" else v);
                    default = [ ];
                    description = "List of ${name}. If files are added via url, make sure the service has access to them!";
                    type = lib.types.listOf (lib.types.either lib.types.str lib.types.path);
                  };
              in
              {
                allow_list = listOption "allowlists";
                include_subdomains = lib.mkEnableOption "Include subdomains";
                lists = listOption "blocklists";
              };
          };

          freeformType = settingsFormat.type;
        };
      };

      supplementaryGroups = lib.mkOption {
        default = [ ];
        description = "Adds additional groups to the crab-hole service. Can be useful to prevent permission issues.";
        example = [ "acme" ];
        type = lib.types.listOf lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."crab-hole.toml".source = cfg.configFile;

    services.crab-hole.configFile = lib.mkDefault (
      checkConfig (settingsFormat.generate "crab-hole.toml" cfg.settings)
    );

    systemd.services.crab-hole = {
      after = [ "network-online.target" ];
      description = "Crab-hole dns server";
      environment.HOME = "/var/lib/crab-hole";
      restartTriggers = [ cfg.configFile ];

      serviceConfig = {
        AmbientCapabilities = "CAP_NET_BIND_SERVICE";
        CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
        DynamicUser = true;
        ExecStart = lib.getExe cfg.package;
        Restart = "on-failure";
        RestartSec = 1;
        StateDirectory = "crab-hole";
        SupplementaryGroups = cfg.supplementaryGroups;
        Type = "simple";
        WorkingDirectory = "/var/lib/crab-hole";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };

    # Warning due to DNSSec issue in crab-hole
    warnings = lib.optional (cfg.settings.upstream.options.validate or false) ''
      Validate options will ONLY allow DNSSec domains. See https://github.com/LuckyTurtleDev/crab-hole/issues/29
    '';
  };

  # Readme from upstream
  meta.doc = ./crab-hole.md;

  meta.maintainers = [
    lib.maintainers.NiklasVousten
  ];
}
