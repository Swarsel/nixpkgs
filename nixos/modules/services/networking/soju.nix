{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.soju;
  stateDir = "/var/lib/soju";
  runtimeDir = "/run/soju";
  listen = cfg.listen ++ optional cfg.adminSocket.enable "unix+admin://${runtimeDir}/admin";
  listenCfg = concatMapStringsSep "\n" (l: "listen ${l}") listen;
  tlsCfg = optionalString (
    cfg.tlsCertificate != null
  ) "tls ${cfg.tlsCertificate} ${cfg.tlsCertificateKey}";
  logCfg = optionalString cfg.enableMessageLogging "message-store fs ${stateDir}/logs";

  configFile = pkgs.writeText "soju.conf" ''
    ${listenCfg}
    hostname ${cfg.hostName}
    ${tlsCfg}
    ${logCfg}
    http-origin ${concatStringsSep " " cfg.httpOrigins}
    accept-proxy-ip ${concatStringsSep " " cfg.acceptProxyIP}

    ${cfg.extraConfig}
  '';

  sojuctl = pkgs.writeShellScriptBin "sojuctl" ''
    exec ${lib.getExe' cfg.package "sojuctl"} --config ${cfg.configFile} "$@"
  '';
in
{
  ###### interface

  options.services.soju = {
    enable = mkEnableOption "soju";
    package = mkPackageOption pkgs "soju" { };

    acceptProxyIP = mkOption {
      default = [ ];

      description = ''
        Allow the specified IPs to act as a proxy. Proxys have the ability to
        overwrite the remote and local connection addresses (via the X-Forwarded-\*
        HTTP header fields). The special name "localhost" accepts the loopback
        addresses 127.0.0.0/8 and ::1/128. By default, all IPs are rejected.
      '';

      type = types.listOf types.str;
    };

    adminSocket.enable = mkOption {
      default = true;

      description = ''
        Listen for admin connections from sojuctl at /run/soju/admin.
      '';

      type = types.bool;
    };

    configFile = mkOption {
      default = configFile;
      defaultText = "Config file generated from other options.";

      description = ''
        Path to config file. If this option is set, it will override any
        configuration done using other options, including {option}`extraConfig`.
      '';

      example = literalExpression "./soju.conf";
      type = types.path;
    };

    enableMessageLogging = mkOption {
      default = true;
      description = "Whether to enable message logging.";
      type = types.bool;
    };

    extraConfig = mkOption {
      default = "";
      description = "Lines added verbatim to the generated configuration file.";
      type = types.lines;
    };

    hostName = mkOption {
      default = config.networking.hostName;
      defaultText = literalExpression "config.networking.hostName";
      description = "Server hostname.";
      type = types.str;
    };

    httpOrigins = mkOption {
      default = [ ];

      description = ''
        List of allowed HTTP origins for WebSocket listeners. The parameters are
        interpreted as shell patterns, see
        {manpage}`glob(7)`.
      '';

      type = types.listOf types.str;
    };

    listen = mkOption {
      default = [ ":6697" ];

      description = ''
        Where soju should listen for incoming connections. See the
        `listen` directive in
        {manpage}`soju(1)`.
      '';

      type = types.listOf types.str;
    };

    tlsCertificate = mkOption {
      default = null;
      description = "Path to server TLS certificate.";
      example = "/var/host.cert";
      type = types.nullOr types.path;
    };

    tlsCertificateKey = mkOption {
      default = null;
      description = "Path to server TLS certificate key.";
      example = "/var/host.key";
      type = types.nullOr types.path;
    };
  };

  ###### implementation

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = (cfg.tlsCertificate != null) == (cfg.tlsCertificateKey != null);

        message = ''
          services.soju.tlsCertificate and services.soju.tlsCertificateKey
          must both be specified to enable TLS.
        '';
      }
    ];

    environment.systemPackages = [ sojuctl ];

    systemd.services.soju = {
      after = [ "network-online.target" ];
      description = "soju IRC bouncer";
      documentation = [ "man:soju(1)" ];

      serviceConfig = {
        DynamicUser = true;
        ExecReload = "${lib.getExe' pkgs.coreutils "kill"} -HUP $MAINPID";
        ExecStart = "${lib.getExe' cfg.package "soju"} -config ${cfg.configFile}";
        Restart = "always";
        RuntimeDirectory = "soju";
        StateDirectory = "soju";
        WorkingDirectory = stateDir;
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };

  meta.maintainers = with maintainers; [ malte-v ];
}
