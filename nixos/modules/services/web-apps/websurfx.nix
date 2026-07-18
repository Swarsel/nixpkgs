{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.websurfx;
  settingsFormat = pkgs.formats.lua { asBindings = true; };
  settingsFile = settingsFormat.generate "config.lua" cfg.settings;
in
{
  options = {
    services.websurfx = {
      enable = lib.mkEnableOption "Websurfx, a metasearch engine";
      package = lib.mkPackageOption pkgs "websurfx" { };
      openFirewall = lib.mkEnableOption "Whether to open the used port in the firewall";

      settings = lib.mkOption {
        default = { };

        description = ''
          Configuration options for Websurfx, see
          [websurfx/config.lua](https://github.com/neon-mmd/websurfx/blob/rolling/websurfx/config.lua)
          for supported values.
        '';

        type = lib.types.submodule {
          options.binding_ip = lib.mkOption {
            default = "127.0.0.1";
            description = "IP address on which the server should be launched";
            type = lib.types.str;
          };

          options.port = lib.mkOption {
            default = 4567;
            description = "Port on which the server should be launched";
            type = lib.types.port;
          };

          freeformType = settingsFormat.type;
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.settings.port ];

    services.websurfx.settings = {
      animation = lib.mkDefault "simple-frosted-glow";
      # Caching
      #redis_url = "redis://127.0.0.1:8082"; # The nixpkgs build doesn't have the redis-cache feature enabled
      cache_expiry_time = lib.mkDefault 600;
      client_connection_keep_alive = lib.mkDefault 120;
      # Website
      colorscheme = lib.mkDefault "catppuccin-mocha";
      debug = lib.mkDefault false;
      https_adaptive_window_size = lib.mkDefault true;
      # General
      logging = lib.mkDefault true;
      number_of_https_connections = lib.mkDefault 10;
      operating_system_tls_certificates = lib.mkDefault true;
      pool_idle_connection_timeout = lib.mkDefault 30;
      # Server
      production_use = lib.mkDefault false;
      proxy = lib.mkDefault null;

      rate_limiter = {
        number_of_requests = lib.mkDefault 20;
        time_limit = lib.mkDefault 3;
      };

      request_timeout = lib.mkDefault 30;
      # Search
      safe_search = lib.mkDefault 2;
      tcp_connection_keep_alive = lib.mkDefault 30;
      theme = lib.mkDefault "simple";
      threads = lib.mkDefault 10;

      # Search Engines
      upstream_search_engines = {
        Bing = lib.mkDefault false;
        Brave = lib.mkDefault false;
        DuckDuckGo = lib.mkDefault true;
        LibreX = lib.mkDefault false;
        Mojeek = lib.mkDefault false;
        Searx = lib.mkDefault false;
        Startpage = lib.mkDefault false;
        Wikipedia = lib.mkDefault true;
        Yahoo = lib.mkDefault false;
      };
    };

    systemd.services.websurfx = {
      after = [ "network-online.target" ];
      description = "Websurfx, a metasearch engine";

      serviceConfig = {
        BindReadOnlyPaths = [ "${settingsFile}:%t/websurfx/.config/websurfx/config.lua" ];
        DynamicUser = true;
        Environment = [ "HOME=%t/websurfx" ];
        ExecStart = lib.getExe cfg.package;
        RuntimeDirectory = "websurfx";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };

  meta.maintainers = [ lib.maintainers.SchweGELBin ];
}
