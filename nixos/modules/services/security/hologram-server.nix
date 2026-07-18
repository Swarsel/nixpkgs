{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.hologram-server;

  cfgFile = pkgs.writeText "hologram-server.json" (
    builtins.toJSON {
      aws = {
        account = cfg.awsAccount;
        defaultrole = cfg.awsDefaultRole;
      };

      cachetimeout = cfg.cacheTimeoutSeconds;

      ldap = {
        baseDN = cfg.ldapBaseDN;

        bind = {
          dn = cfg.ldapBindDN;
          password = cfg.ldapBindPassword;
        };

        enableldapRoles = cfg.enableLdapRoles;
        groupClassAttr = cfg.groupClassAttr;
        host = cfg.ldapHost;
        insecureldap = cfg.ldapInsecure;
        roleAttr = cfg.roleAttr;
        userattr = cfg.ldapUserAttr;
      };

      listen = cfg.listenAddress;
      stats = cfg.statsAddress;
    }
  );
in
{
  options = {
    services.hologram-server = {
      enable = lib.mkOption {
        default = false;
        description = "Whether to enable the Hologram server for AWS instance credentials";
        type = lib.types.bool;
      };

      awsAccount = lib.mkOption {
        description = "AWS account number";
        type = lib.types.str;
      };

      awsDefaultRole = lib.mkOption {
        description = "AWS default role";
        type = lib.types.str;
      };

      cacheTimeoutSeconds = lib.mkOption {
        default = 3600;
        description = "How often (in seconds) to refresh the LDAP cache";
        type = lib.types.int;
      };

      enableLdapRoles = lib.mkOption {
        default = false;
        description = "Whether to assign user roles based on the user's LDAP group memberships";
        type = lib.types.bool;
      };

      groupClassAttr = lib.mkOption {
        default = "groupOfNames";
        description = "The objectclass attribute to search for groups when enableLdapRoles is true";
        type = lib.types.str;
      };

      ldapBaseDN = lib.mkOption {
        description = "The base DN for your Hologram users";
        type = lib.types.str;
      };

      ldapBindDN = lib.mkOption {
        description = "DN of account to use to query the LDAP server";
        type = lib.types.str;
      };

      ldapBindPassword = lib.mkOption {
        description = "Password of account to use to query the LDAP server";
        type = lib.types.str;
      };

      ldapHost = lib.mkOption {
        description = "Address of the LDAP server to use";
        type = lib.types.str;
      };

      ldapInsecure = lib.mkOption {
        default = false;
        description = "Whether to connect to LDAP over SSL or not";
        type = lib.types.bool;
      };

      ldapUserAttr = lib.mkOption {
        default = "cn";
        description = "The LDAP attribute for usernames";
        type = lib.types.str;
      };

      listenAddress = lib.mkOption {
        default = "0.0.0.0:3100";
        description = "Address and port to listen on";
        type = lib.types.str;
      };

      roleAttr = lib.mkOption {
        default = "businessCategory";
        description = "Which LDAP group attribute to search for authorized role ARNs";
        type = lib.types.str;
      };

      statsAddress = lib.mkOption {
        default = "";
        description = "Address of statsd server";
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.hologram-server = {
      after = [ "network.target" ];
      description = "Provide EC2 instance credentials to machines outside of EC2";

      serviceConfig = {
        ExecStart = "${pkgs.hologram}/bin/hologram-server --debug --conf ${cfgFile}";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
