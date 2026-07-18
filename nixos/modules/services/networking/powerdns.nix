{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.powerdns;
  configDir = pkgs.writeTextDir "pdns.conf" "${cfg.extraConfig}";
  finalConfigDir = if cfg.secretFile == null then configDir else "/run/pdns";
in
{
  options = {
    services.powerdns = {
      enable = mkEnableOption "PowerDNS domain name server";

      extraConfig = mkOption {
        default = "launch=bind";

        description = ''
          PowerDNS configuration. Refer to
          <https://doc.powerdns.com/authoritative/settings.html>
          for details on supported values.
        '';

        type = types.lines;
      };

      secretFile = mkOption {
        default = null;

        description = ''
          Environment variables from this file will be interpolated into the
          final config file using envsubst with this syntax: `$ENVIRONMENT`
          or `''${VARIABLE}`.
          The file should contain lines formatted as `SECRET_VAR=SECRET_VALUE`.
          This is useful to avoid putting secrets into the nix store.
        '';

        example = "/run/keys/powerdns.env";
        type = types.nullOr types.path;
      };
    };
  };

  config = mkIf cfg.enable {

    environment.etc.pdns.source = finalConfigDir;
    systemd.packages = [ pkgs.pdns ];

    systemd.services.pdns = {
      after = [
        "network.target"
        "mysql.service"
        "postgresql.target"
        "openldap.service"
      ];

      serviceConfig = {
        EnvironmentFile = lib.optional (cfg.secretFile != null) cfg.secretFile;

        ExecStart = [
          ""
          "${pkgs.pdns}/bin/pdns_server --config-dir=${finalConfigDir} --guardian=no --daemon=no --disable-syslog --log-timestamp=no --write-pid=no"
        ];

        ExecStartPre = lib.optional (cfg.secretFile != null) (
          pkgs.writeShellScript "pdns-pre-start" ''
            umask 077
            ${pkgs.envsubst}/bin/envsubst -i "${configDir}/pdns.conf" > ${finalConfigDir}/pdns.conf
          ''
        );
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.pdns = { };

    users.users.pdns = {
      description = "PowerDNS";
      group = "pdns";
      isSystemUser = true;
    };

  };
}
