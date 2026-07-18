{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.umurmur;
  dumpAttrset =
    x: top_level:
    (lib.optionalString (!top_level) "{")
    + (lib.concatLines (lib.mapAttrsToList (name: value: "${name} = ${toConfigValue value false};") x))
    + (lib.optionalString (!top_level) "}");
  dumpList = x: top_level: "(${lib.concatStringsSep ",\n" (map (y: "${toConfigValue y false}") x)})";

  toConfigValue =
    x: top_level:
    if builtins.isList x then
      dumpList x top_level
    else if builtins.isAttrs x then
      dumpAttrset x top_level
    else
      builtins.toJSON x;
  dumpCfg = x: toConfigValue x true;
  configAttrs = lib.filterAttrsRecursive (name: value: value != null) cfg.settings;
  configFile = pkgs.writeTextFile {
    checkPhase = ''
      ${lib.getExe cfg.package} -t -c "$target"
    '';

    name = "umurmur.conf";
    text = "\n" + (dumpCfg configAttrs) + "\n";
  };
in
{
  options = {
    services.umurmur = {
      enable = lib.mkEnableOption "uMurmur Mumble server";
      package = lib.mkPackageOption pkgs "umurmur" { };

      configFile = lib.mkOption rec {
        default = configFile;
        defaultText = description;
        description = "Configuration file, default is generated from config.service.umurmur.settings";
        type = lib.types.path;
      };

      openFirewall = lib.mkOption {
        default = false;

        description = ''
          Open ports in the firewall for the uMurmur Mumble server.
        '';

        type = lib.types.bool;
      };

      settings = lib.mkOption {
        default = { };
        description = "Settings of uMurmur. For reference see <https://github.com/umurmur/umurmur/blob/master/umurmur.conf.example>";

        type = lib.types.submodule {
          options = {
            bindaddr = lib.mkOption {
              default = "0.0.0.0";
              description = "IPv4 address to bind to. Defaults binding on all addresses.";
              type = lib.types.str;
            };

            bindaddr6 = lib.mkOption {
              default = "::";
              description = "IPv6 address to bind to. Defaults binding on all addresses.";
              type = lib.types.str;
            };

            bindport = lib.mkOption {
              default = 64739;
              description = "Port to bind to (UDP and TCP).";
              type = lib.types.port;
            };

            ca_path = lib.mkOption {
              default = null;
              description = "Path to your SSL CA certificate.";
              type = lib.types.nullOr lib.types.str;
            };

            certificate = lib.mkOption {
              default = "/var/lib/private/umurmur/cert.crt";
              description = "Path to your SSL certificate. Generates self-signed automatically if not exists.";
              type = lib.types.str;
            };

            channel_links = lib.mkOption {
              default = [ ];
              description = "Channel tree definitions.";

              example = [
                {
                  destination = "Red team";
                  source = "Lobby";
                }
              ];

              type = lib.types.listOf lib.types.attrs;
            };

            channels = lib.mkOption {
              default = [
                {
                  description = "Root channel.";
                  name = "root";
                  noenter = false;
                  parent = "";
                }
              ];

              description = "Channel tree definitions.";
              type = lib.types.listOf lib.types.attrs;
            };

            default_channel = lib.mkOption {
              default = "root";
              description = "The channel in which users will appear in when connecting.";
              type = lib.types.str;
            };

            max_bandwidth = lib.mkOption {
              default = 48000;

              description = ''
                Maximum bandwidth (in bits per second) that clients may send
                speech at.
              '';

              type = lib.types.int;
            };

            max_users = lib.mkOption {
              default = 10;
              description = "Maximum number of concurrent clients allowed.";
              type = lib.types.int;
            };

            password = lib.mkOption {
              default = null;
              description = "Required password to join server, if specified.";
              type = lib.types.nullOr lib.types.str;
            };

            private_key = lib.mkOption {
              default = "/var/lib/private/umurmur/key.key";
              description = "Path to your SSL key. Generates self-signed automatically if not exists.";
              type = lib.types.str;
            };

            welcometext = lib.mkOption {
              default = "Welcome to uMurmur!";
              description = "Welcome message for connected clients.";
              type = lib.types.nullOr lib.types.str;
            };

          };

          freeformType =
            let
              valueType =
                with lib.types;
                (attrsOf (oneOf [
                  bool
                  int
                  float
                  str
                  path
                  (listOf valueType)
                ]))
                // {
                  description = "uMurmur config value";
                };
            in
            valueType;
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.settings.bindport ];
      allowedUDPPorts = [ cfg.settings.bindport ];
    };

    systemd.services.umurmur = {
      after = [ "network.target" ];
      description = "uMurmur Mumble Server";

      serviceConfig = {
        AmbientCapabilities = [ "" ];
        CapabilityBoundingSet = [ "" ];
        DevicePolicy = "closed";
        DynamicUser = true;
        ExecStart = "${lib.getExe cfg.package} -d -c ${cfg.configFile}";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
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
        ProtectSystem = "full";
        ReadWritePaths = "/dev/shm";
        RemoveIPC = true;
        Restart = "on-failure";

        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = "umurmur";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@cpu-emulation"
          "~@debug"
          "~@mount"
          "~@obsolete"
          "~@privileged"
          "~@resources"
        ];

        Type = "exec";
        # hardening
        UMask = 27;
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network.target" ];
    };
  };

  meta.doc = ./umurmur.md;
  meta.maintainers = with lib.maintainers; [ _3JlOy-PYCCKUi ];
}
