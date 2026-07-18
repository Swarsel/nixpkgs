{
  config,
  lib,
  pkgs,
  ...
}:

let

  cfg = config.services.devpi-server;
  package = cfg.package.override { inherit (cfg) extraPackages; };
  secretsFileName = "devpi-secret-file";
  stateDirName = "devpi";
  runtimeDir = "/run/${stateDirName}";
  serverDir = "/var/lib/${stateDirName}";

in

{

  options.services.devpi-server = {

    enable = lib.mkEnableOption "Devpi Server";
    package = lib.mkPackageOption pkgs "devpi-server" { };

    extraPackages = lib.mkOption {
      default = (ps: [ ]);
      defaultText = lib.literalExpression "ps: [ ]";

      description = ''
        Plugins and extra Python packages to be available to devpi-server.
      '';

      example = lib.literalExpression ''
        ps: with ps; [ devpi-web devpi-ldap ]
      '';

      type =
        with lib.types;
        coercedTo (listOf lib.types.package) (v: (_: v)) (functionTo (listOf lib.types.package));
    };

    host = lib.mkOption {
      default = "localhost";

      description = ''
        domain/ip address to listen on
      '';

      type = lib.types.str;
    };

    openFirewall = lib.mkEnableOption "opening the default ports in the firewall for Devpi Server";

    port = lib.mkOption {
      default = 3141;
      description = "The port on which Devpi Server will listen.";
      type = lib.types.port;
    };

    primaryUrl = lib.mkOption {
      description = "Url for the primary node. Required option for replica nodes.";
      type = lib.types.str;
    };

    replica = lib.mkOption {
      default = false;

      description = ''
        Run node as a replica.
        Requires the secretFile option and the primaryUrl to be enabled.
      '';

      type = lib.types.bool;
    };

    secretFile = lib.mkOption {
      default = null;

      description = ''
        Path to a shared secret file used for synchronization,
        Required for all nodes in a replica/primary setup.
      '';

      type = lib.types.nullOr lib.types.path;
    };
  };

  config = lib.mkIf cfg.enable {

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };

    systemd.services.devpi-server = {
      enable = true;
      after = [ "network-online.target" ];
      description = "devpi PyPI-compatible server";
      documentation = [ "https://devpi.net/docs/devpi/devpi/stable/+d/index.html" ];

      # Since at least devpi-server 6.10.0, devpi requires the secrets file to
      # have 0600 permissions.
      preStart = ''
        ${lib.optionalString (
          !isNull cfg.secretFile
        ) "install -Dm 0600 \${CREDENTIALS_DIRECTORY}/devpi-secret ${runtimeDir}/${secretsFileName}"}

        if [ -f ${serverDir}/.nodeinfo ]; then
          # already initialized the package index, exit gracefully
          exit 0
        fi
        ${package}/bin/devpi-init --serverdir ${serverDir} ''
      + lib.optionalString cfg.replica "--role=replica --master-url=${cfg.primaryUrl}";

      serviceConfig = {
        DynamicUser = true;

        ExecStart =
          let
            args = [
              "--request-timeout=5"
              "--serverdir=${serverDir}"
              "--host=${cfg.host}"
              "--port=${toString cfg.port}"
            ]
            ++ lib.optionals (!isNull cfg.secretFile) [
              "--secretfile=${runtimeDir}/${secretsFileName}"
            ]
            ++ (
              if cfg.replica then
                [
                  "--role=replica"
                  "--master-url=${cfg.primaryUrl}"
                ]
              else
                [ "--role=master" ]
            );
          in
          "${package}/bin/devpi-server ${lib.concatStringsSep " " args}";

        LoadCredential = lib.mkIf (!isNull cfg.secretFile) [
          "devpi-secret:${cfg.secretFile}"
        ];

        PrivateDevices = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        Restart = "always";
        RuntimeDirectory = stateDirName;
        StateDirectory = stateDirName;
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [
    cafkafk
    confus
  ];
}
