{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.blendfarm;
  json = pkgs.formats.json { };
  configFile = json.generate "ServerSettings" (defaultConfig // cfg.serverConfig);
  defaultConfig = {
    BasicSecurityPassword = null;
    BroadcastPort = 16342;
    BypassScriptUpdate = false;
    Port = 15000;
  };
in
{
  options.services.blendfarm = with lib.types; {
    enable = lib.mkEnableOption "Blendfarm, a render farm management software for Blender";
    package = lib.mkPackageOption pkgs "blendfarm" { };

    basicSecurityPasswordFile = lib.mkOption {
      default = null;

      description = ''
        Path to the password file the client needs to connect to the server.
              The password must not contain a forward slash.'';

      type = nullOr str;
    };

    blenderPackage = lib.mkPackageOption pkgs "blender" { };

    group = lib.mkOption {
      default = "blendfarm";
      description = "Group under which blendfarm runs.";
      type = str;
    };

    openFirewall = lib.mkEnableOption "allowing blendfarm network access through the firewall";

    serverConfig = lib.mkOption {
      default = defaultConfig;
      description = "Server configuration";

      type = submodule {
        options = {
          BroadcastPort = lib.mkOption {
            default = 16342;
            description = "Default port blendfarm server advertises itself on.";
            type = types.port;
          };

          BypassScriptUpdate = lib.mkOption {
            default = false;
            description = "Prevents blendfarm from replacing the .py self-generated scripts.";
            type = bool;
          };

          Port = lib.mkOption {
            default = 15000;
            description = "Default port blendfarm server listens on.";
            type = types.port;
          };
        };

        freeformType = attrsOf anything;
      };
    };

    user = lib.mkOption {
      default = "blendfarm";
      description = "User under which blendfarm runs.";
      type = str;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    networking.firewall = lib.optionalAttrs (cfg.openFirewall) {
      allowedTCPPorts = [ cfg.serverConfig.Port ];
      allowedUDPPorts = [ cfg.serverConfig.BroadcastPort ];
    };

    systemd.services.blendfarm-server = {
      after = [ "network-online.target" ];
      description = "blendfarm server";
      path = [ cfg.blenderPackage ];

      preStart = ''
        rm -f ServerSettings
        install -m640 ${configFile} ServerSettings
        if [ ! -d "BlenderData/nix-blender-linux64" ]; then
          mkdir -p BlenderData/nix-blender-linux64
          echo "nix-blender" > VersionCustom
        fi
        rm -f BlenderData/nix-blender-linux64/blender
        ln -s ${lib.getExe cfg.blenderPackage} BlenderData/nix-blender-linux64/blender
      ''
      + lib.optionalString (cfg.basicSecurityPasswordFile != null) ''
        BLENDFARM_PASSWORD=$(${pkgs.systemd}/bin/systemd-creds cat BLENDFARM_PASS_FILE)
        sed -i "s/null/\"$BLENDFARM_PASSWORD\"/g" ServerSettings
      '';

      serviceConfig = {
        CapabilityBoundingSet = "";
        DynamicUser = true;
        ExecStart = "${cfg.package}/bin/LogicReinc.BlendFarm.Server";
        Group = cfg.group;

        LoadCredential = lib.optional (
          cfg.basicSecurityPasswordFile != null
        ) "BLENDFARM_PASS_FILE:${cfg.basicSecurityPasswordFile}";

        LockPersonality = true;
        LogsDirectory = "blendfarm";
        PrivateDevices = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ReadWritePaths = "";

        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        StateDirectory = "blendfarm";
        StateDirectoryMode = "0755";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "@chown"
        ];

        UMask = "0066";
        User = cfg.user;
        WorkingDirectory = "/var/lib/blendfarm";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };

    users.groups.blendfarm = { };

    users.users.blendfarm = {
      group = "blendfarm";
      isSystemUser = true;
    };
  };

  meta.maintainers = with lib.maintainers; [ gador ];
}
