{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

let
  inherit (lib) mapAttrs;
  inherit (utils) escapeSystemdExecArgs;

  cfg = config.services.kerberos_server;
  package = config.security.krb5.package;

  aclConfigs = lib.pipe cfg.settings.realms [
    (mapAttrs (
      name:
      { acl, ... }:
      lib.concatMapStringsSep "\n" (
        {
          access,
          principal,
          target,
          ...
        }:
        if target != "*" && target != "" then
          "${principal}\t${lib.concatStringsSep "," (lib.toList access)}\t${target}"
        else
          "${principal}\t${lib.concatStringsSep "," (lib.toList access)}"
      ) acl
    ))
    (lib.mapAttrsToList (
      name: text: {
        acl_file = pkgs.writeText "${name}.acl" text;
        dbname = "/var/lib/heimdal/heimdal";
      }
    ))
  ];

  finalConfig = cfg.settings // {
    kdc = (cfg.settings.kdc or { }) // {
      database = aclConfigs;
    };

    realms = mapAttrs (_: v: removeAttrs v [ "acl" ]) (cfg.settings.realms or { });
  };

  format = import ../../../security/krb5/krb5-conf-format.nix { inherit pkgs lib; } {
    enableKdcACLEntries = true;
  };

  kdcConfFile = format.generate "kdc.conf" finalConfig;
in

{
  config = lib.mkIf (cfg.enable && package.passthru.implementation == "heimdal") {
    environment.etc."heimdal-kdc/kdc.conf".source = kdcConfFile;

    systemd.services.kadmind = {
      description = "Kerberos Administration Daemon";

      documentation = [
        "man:kadmind(8)"
        "info:heimdal"
      ];

      partOf = [ "kerberos-server.target" ];
      restartTriggers = [ kdcConfFile ];

      serviceConfig = {
        ExecStart = "${package}/libexec/kadmind --config-file=/etc/heimdal-kdc/kdc.conf";
        Slice = "system-kerberos-server.slice";
        StateDirectory = "heimdal";
      };

      wantedBy = [ "kerberos-server.target" ];
    };

    systemd.services.kdc = {
      description = "Key Distribution Center daemon";

      documentation = [
        "man:kdc(8)"
        "info:heimdal"
      ];

      partOf = [ "kerberos-server.target" ];
      restartTriggers = [ kdcConfFile ];

      serviceConfig = {
        ExecStart = escapeSystemdExecArgs (
          [
            "${package}/libexec/kdc"
            "--config-file=/etc/heimdal-kdc/kdc.conf"
          ]
          ++ cfg.extraKDCArgs
        );

        Slice = "system-kerberos-server.slice";
        StateDirectory = "heimdal";
      };

      wantedBy = [ "kerberos-server.target" ];
    };

    systemd.services.kpasswdd = {
      description = "Kerberos Password Changing daemon";

      documentation = [
        "man:kpasswdd(8)"
        "info:heimdal"
      ];

      partOf = [ "kerberos-server.target" ];
      restartTriggers = [ kdcConfFile ];

      serviceConfig = {
        ExecStart = "${package}/libexec/kpasswdd";
        Slice = "system-kerberos-server.slice";
        StateDirectory = "heimdal";
      };

      wantedBy = [ "kerberos-server.target" ];
    };

    systemd.tmpfiles.settings."10-heimdal" =
      let
        databases = lib.pipe finalConfig.kdc.database [
          (map (dbAttrs: dbAttrs.dbname or null))
          (lib.filter (x: x != null))
          lib.unique
        ];
      in
      lib.genAttrs databases (_: {
        d = {
          group = "root";
          mode = "0700";
          user = "root";
        };
      });
  };
}
