{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.erigon;

  settingsFormat = pkgs.formats.toml { };
  configFile = settingsFormat.generate "config.toml" cfg.settings;
in
{

  options = {
    services.erigon = {
      enable = lib.mkEnableOption "Ethereum implementation on the efficiency frontier";
      package = lib.mkPackageOption pkgs "erigon" { };

      extraArgs = lib.mkOption {
        default = [ ];
        description = "Additional arguments passed to Erigon";
        type = lib.types.listOf lib.types.str;
      };

      secretJwtPath = lib.mkOption {
        default = "";

        description = ''
          Path to the secret jwt used for the http api authentication.
        '';

        example = "config.age.secrets.ERIGON_JWT.path";
        type = lib.types.path;
      };

      settings = lib.mkOption {
        defaultText = lib.literalExpression ''
          {
            datadir = "/var/lib/erigon";
            chain = "mainnet";
            http = true;
            "http.port" = 8545;
            "http.api" = ["eth" "debug" "net" "trace" "web3" "erigon"];
            ws = true;
            port = 30303;
            "authrpc.port" = 8551;
            "torrent.port" = 42069;
            "private.api.addr" = "localhost:9090";
            "log.console.verbosity" = 3; # info
          }
        '';

        description = ''
          Configuration for Erigon
          Refer to <https://github.com/ledgerwatch/erigon#usage> for details on supported values.
        '';

        example = {
          "authrpc.port" = 8551;
          chain = "mainnet";
          datadir = "/var/lib/erigon";
          http = true;

          "http.api" = [
            "eth"
            "debug"
            "net"
            "trace"
            "web3"
            "erigon"
          ];

          "http.port" = 8545;
          "log.console.verbosity" = 3; # info
          port = 30303;
          "private.api.addr" = "localhost:9090";
          "torrent.port" = 42069;
          ws = true;
        };

        type = settingsFormat.type;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Default values are the same as in the binary, they are just written here for convenience.
    services.erigon.settings = {
      "authrpc.port" = lib.mkDefault 8551;
      chain = lib.mkDefault "mainnet";
      datadir = lib.mkDefault "/var/lib/erigon";
      http = lib.mkDefault true;

      "http.api" = lib.mkDefault [
        "eth"
        "debug"
        "net"
        "trace"
        "web3"
        "erigon"
      ];

      "http.port" = lib.mkDefault 8545;
      "log.console.verbosity" = lib.mkDefault 3; # info
      port = lib.mkDefault 30303;
      "private.api.addr" = lib.mkDefault "localhost:9090";
      "torrent.port" = lib.mkDefault 42069;
      ws = lib.mkDefault true;
    };

    systemd.services.erigon = {
      after = [ "network.target" ];
      description = "Erigon ethereum implemenntation";

      serviceConfig = {
        CapabilityBoundingSet = "";
        DynamicUser = true;
        ExecStart = "${cfg.package}/bin/erigon --config ${configFile} --authrpc.jwtsecret=%d/ERIGON_JWT ${lib.escapeShellArgs cfg.extraArgs}";
        LoadCredential = "ERIGON_JWT:${cfg.secretJwtPath}";
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "noaccess";
        RemoveIPC = true;
        Restart = "on-failure";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = "erigon";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
        ];
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
