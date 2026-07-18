{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.snmpd;
  configFile =
    if cfg.configText != "" then
      pkgs.writeText "snmpd.cfg" ''
        ${cfg.configText}
      ''
    else
      null;
in
{
  options.services.snmpd = {
    enable = lib.mkEnableOption "snmpd";
    package = lib.mkPackageOption pkgs "net-snmp" { };

    configFile = lib.mkOption {
      default = configFile;
      defaultText = lib.literalMD "The value of {option}`configText`.";

      description = ''
        Path to the snmpd.conf file. By default, if {option}`configText` is set,
        a config file will be automatically generated.
      '';

      type = lib.types.path;
    };

    configText = lib.mkOption {
      default = "";

      description = ''
        The contents of the snmpd.conf. If the {option}`configFile` option
        is set, this value will be ignored.

        Note that the contents of this option will be added to the Nix
        store as world-readable plain text, {option}`configFile` can be used in
        addition to a secret management tool to protect sensitive data.
      '';

      type = lib.types.lines;
    };

    listenAddress = lib.mkOption {
      default = "0.0.0.0";

      description = ''
        The address to listen on for SNMP and AgentX messages.
      '';

      example = "127.0.0.1";
      type = lib.types.str;
    };

    openFirewall = lib.mkOption {
      default = false;

      description = ''
        Open port in firewall for snmpd.
      '';

      type = lib.types.bool;
    };

    port = lib.mkOption {
      default = 161;

      description = ''
        The port to listen on for SNMP and AgentX messages.
      '';

      type = lib.types.port;
    };

  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedUDPPorts = lib.mkIf cfg.openFirewall [
      cfg.port
    ];

    systemd.services."snmpd" = {
      after = [ "network.target" ];
      description = "Simple Network Management Protocol (SNMP) daemon.";

      serviceConfig = {
        ExecStart = "${lib.getExe' cfg.package "snmpd"} -f -Lo -c ${cfg.configFile} ${cfg.listenAddress}:${toString cfg.port}";
        Type = "simple";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = [ lib.maintainers.eliandoran ];

}
