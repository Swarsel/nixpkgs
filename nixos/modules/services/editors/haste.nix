{
  config,
  lib,
  pkgs,
  ...
}:
let
  pkg = pkgs.haste-server;
  cfg = config.services.haste-server;

  format = pkgs.formats.json { };
in
{
  options.services.haste-server = {
    enable = lib.mkEnableOption "haste-server";
    openFirewall = lib.mkEnableOption "firewall passthrough for haste-server";

    settings = lib.mkOption {
      description = ''
        Configuration for haste-server.
        For documentation see [project readme](https://github.com/toptal/haste-server#settings)
      '';

      type = format.type;
    };
  };

  config = lib.mkIf (cfg.enable) {
    networking.firewall.allowedTCPPorts = lib.mkIf (cfg.openFirewall) [ cfg.settings.port ];

    services.haste-server = {
      settings = {
        documents = {
          about = lib.mkDefault "${pkg}/share/haste-server/about.md";
        };

        host = lib.mkDefault "::";

        keyGenerator = lib.mkDefault {
          type = "phonetic";
        };

        keyLength = lib.mkDefault 10;

        logging = lib.mkDefault [
          {
            colorize = true;
            level = "verbose";
            type = "Console";
          }
        ];

        maxLength = lib.mkDefault 400000;
        port = lib.mkDefault 7777;

        rateLimits = {
          categories = {
            normal = {
              every = lib.mkDefault 60000;
              totalRequests = lib.mkDefault 500;
            };
          };
        };

        recompressStaticAssets = lib.mkDefault false;
        staticMaxAge = lib.mkDefault 86400;

        storage = lib.mkDefault {
          type = "file";
        };
      };
    };

    systemd.services.haste-server = {
      after = [ "network.target" ];

      path = with pkgs; [
        pkg
        coreutils
      ];

      requires = [ "network.target" ];

      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${pkg}/bin/haste-server ${format.generate "config.json" cfg.settings}";
        StateDirectory = "haste-server";
        User = "haste-server";
        WorkingDirectory = "/var/lib/haste-server";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
