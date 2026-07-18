{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    boolToString
    concatMapAttrs
    concatStrings
    isBool
    mapAttrsToList
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    optionalAttrs
    types
    mkDefault
    ;
  cfg = config.services.your_spotify;

  configEnv = concatMapAttrs (
    name: value:
    optionalAttrs (value != null) {
      ${name} = if isBool value then boolToString value else toString value;
    }
  ) cfg.settings;

  configFile = pkgs.writeText "your_spotify.env" (
    concatStrings (mapAttrsToList (name: value: "${name}=${value}\n") configEnv)
  );
in
{
  options.services.your_spotify =
    let
      inherit (types)
        nullOr
        port
        str
        path
        package
        ;
    in
    {
      enable = mkEnableOption "your_spotify";
      package = mkPackageOption pkgs "your_spotify" { };

      clientPackage = mkOption {
        description = "Client package to use.";
        type = package;
      };

      enableLocalDB = mkEnableOption "a local mongodb instance";

      nginxVirtualHost = mkOption {
        default = null;

        description = ''
          If set creates an nginx virtual host for the client.
          In most cases this should be the CLIENT_ENDPOINT without
          protocol prefix.
        '';

        type = nullOr str;
      };

      settings = mkOption {
        description = ''
          Your Spotify Configuration. Refer to [Your Spotify](https://github.com/Yooooomi/your_spotify) for definitions and values.
        '';

        example = lib.literalExpression ''
          {
            CLIENT_ENDPOINT = "https://example.com";
            API_ENDPOINT = "https://api.example.com";
            SPOTIFY_PUBLIC = "spotify_client_id";
          }
        '';

        type = types.submodule {
          options = {
            API_ENDPOINT = mkOption {
              description = ''
                The endpoint of your server
                This api has to be reachable from the device you use the website from not from the server.
                This means that for example you may need two nginx virtual hosts if you want to expose this on the
                internet.
                Has to include a protocol Prefix (e.g. `http://`)
              '';

              example = "https://localhost:3000";
              type = str;
            };

            CLIENT_ENDPOINT = mkOption {
              description = ''
                The endpoint of your web application.
                Has to include a protocol Prefix (e.g. `http://`)
              '';

              example = "https://your_spotify.example.org";
              type = str;
            };

            MONGO_ENDPOINT = mkOption {
              default = "mongodb://localhost:27017/your_spotify";
              description = "The endpoint of the Mongo database.";
              type = str;
            };

            PORT = mkOption {
              default = 3000;
              description = "The port of the api server";
              type = port;
            };

            SPOTIFY_PUBLIC = mkOption {
              description = ''
                The public client ID of your Spotify application.
                Refer to: [Creating the Spotify Application](https://github.com/Yooooomi/your_spotify#creating-the-spotify-application)
              '';

              type = str;
            };
          };

          freeformType = types.attrsOf types.str;
        };
      };

      spotifySecretFile = mkOption {
        description = ''
          A file containing the secret key of your Spotify application.
          Refer to: [Creating the Spotify Application](https://github.com/Yooooomi/your_spotify#creating-the-spotify-application).
        '';

        type = path;
      };
    };

  config = mkIf cfg.enable {
    services.mongodb = mkIf cfg.enableLocalDB {
      enable = true;
    };

    services.nginx = mkIf (cfg.nginxVirtualHost != null) {
      enable = true;

      virtualHosts.${cfg.nginxVirtualHost} = {
        locations."/".extraConfig = ''
          add_header Content-Security-Policy "frame-ancestors 'none';" ;
          add_header X-Content-Type-Options "nosniff" ;
          try_files = $uri $uri/ /index.html ;
        '';

        root = cfg.clientPackage;
      };
    };

    services.your_spotify.clientPackage = mkDefault (
      cfg.package.client.override { apiEndpoint = cfg.settings.API_ENDPOINT; }
    );

    systemd.services.your_spotify = {
      after = [ "network.target" ];

      script = ''
        export SPOTIFY_SECRET=$(< "$CREDENTIALS_DIRECTORY/SPOTIFY_SECRET")
        ${lib.getExe' cfg.package "your_spotify_migrate"}
        exec ${lib.getExe cfg.package}
      '';

      serviceConfig = {
        # Hardening
        CapabilityBoundingSet = "";
        DynamicUser = true;
        EnvironmentFile = [ configFile ];
        Group = "your_spotify";
        LimitNOFILE = "1048576";
        LoadCredential = [ "SPOTIFY_SECRET:${cfg.spotifySecretFile}" ];
        LockPersonality = true;
        PrivateDevices = true;
        PrivateTmp = true;
        #MemoryDenyWriteExecute = true; # Leads to coredump because V8 does JIT
        PrivateUsers = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        Restart = "always";

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        StateDirectory = "your_spotify";
        StateDirectoryMode = "0700";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "@pkey"
        ];

        UMask = "0077";
        User = "your_spotify";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ patrickdag ];
}
