{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.g3proxy;

  inherit (lib)
    mkPackageOption
    mkEnableOption
    mkOption
    mkIf
    literalExpression
    ;

  settingsFormat = pkgs.formats.yaml { };
in
{
  options.services.g3proxy = {
    enable = mkEnableOption "g3proxy, a generic purpose forward proxy";
    package = mkPackageOption pkgs "g3proxy" { };

    settings = mkOption {
      default = { };

      description = ''
        Settings of g3proxy.
      '';

      example = literalExpression ''
        {
          server = [{
            name = "test";
            escaper = "default";
            type = "socks_proxy";
            listen = {
              address = "[::]:10086";
            };
          }];
        }
      '';

      type = settingsFormat.type;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.g3proxy = {
      description = "g3proxy server";

      serviceConfig = {
        DevicePolicy = "closed";
        DynamicUser = true;

        ExecStart =
          let
            g3proxy-yaml = settingsFormat.generate "g3proxy.yaml" cfg.settings;
          in
          "${lib.getExe cfg.package} --config-file ${g3proxy-yaml} --systemd --control-dir %t/g3proxy";

        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProcSubset = "pid";
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        RemoveIPC = true;

        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RuntimeDirectory = "g3proxy";
        RuntimeDirectoryMode = "0755";
        StateDirectory = "g3proxy";
        SystemCallArchitectures = "native";
        UMask = "0077";
        WorkingDirectory = "/var/lib/g3proxy";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
