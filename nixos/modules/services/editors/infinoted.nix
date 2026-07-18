{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.infinoted;
in
{
  options.services.infinoted = {
    enable = lib.mkEnableOption "infinoted";
    package = lib.mkPackageOption pkgs "libinfinity" { };

    certificateChain = lib.mkOption {
      default = null;

      description = ''
        Chain of CA-certificates to which our `certificateFile` is relative.
        Optional for TLS.
      '';

      type = lib.types.nullOr lib.types.path;
    };

    certificateFile = lib.mkOption {
      default = null;

      description = ''
        Server certificate to use for TLS
      '';

      type = lib.types.nullOr lib.types.path;
    };

    extraConfig = lib.mkOption {
      default = ''
        [autosave]
        interval=10
      '';

      description = ''
        Additional configuration to append to infinoted.conf
      '';

      type = lib.types.lines;
    };

    group = lib.mkOption {
      default = "infinoted";

      description = ''
        What to call the primary group of the dedicated user under which infinoted is run
      '';

      type = lib.types.str;
    };

    keyFile = lib.mkOption {
      default = null;

      description = ''
        Private key to use for TLS
      '';

      type = lib.types.nullOr lib.types.path;
    };

    passwordFile = lib.mkOption {
      default = null;

      description = ''
        File to read server-wide password from
      '';

      type = lib.types.nullOr lib.types.path;
    };

    plugins = lib.mkOption {
      default = [
        "note-text"
        "note-chat"
        "logging"
        "autosave"
      ];

      description = ''
        Plugins to enable
      '';

      type = lib.types.listOf lib.types.str;
    };

    port = lib.mkOption {
      default = 6523;

      description = ''
        Port to listen on
      '';

      type = lib.types.port;
    };

    rootDirectory = lib.mkOption {
      default = "/var/lib/infinoted/documents/";

      description = ''
        Root of the directory structure to serve
      '';

      type = lib.types.path;
    };

    securityPolicy = lib.mkOption {
      default = "require-tls";

      description = ''
        How strictly to enforce clients connection with TLS.
      '';

      type = lib.types.enum [
        "no-tls"
        "allow-tls"
        "require-tls"
      ];
    };

    user = lib.mkOption {
      default = "infinoted";

      description = ''
        What to call the dedicated user under which infinoted is run
      '';

      type = lib.types.str;
    };
  };

  config = lib.mkIf (cfg.enable) {
    systemd.services.infinoted = {
      after = [ "network.target" ];
      description = "Gobby Dedicated Server";

      preStart = ''
        mkdir -p /var/lib/infinoted
        install -o ${cfg.user} -g ${cfg.group} -m 0600 /dev/null /var/lib/infinoted/infinoted.conf
        cat >>/var/lib/infinoted/infinoted.conf <<EOF
        [infinoted]
        ${lib.optionalString (cfg.keyFile != null) "key-file=${cfg.keyFile}"}
        ${lib.optionalString (cfg.certificateFile != null) "certificate-file=${cfg.certificateFile}"}
        ${lib.optionalString (cfg.certificateChain != null) "certificate-chain=${cfg.certificateChain}"}
        port=${toString cfg.port}
        security-policy=${cfg.securityPolicy}
        root-directory=${cfg.rootDirectory}
        plugins=${lib.concatStringsSep ";" cfg.plugins}
        ${lib.optionalString (cfg.passwordFile != null) "password=$(head -n 1 ${cfg.passwordFile})"}

        ${cfg.extraConfig}
        EOF

        install -o ${cfg.user} -g ${cfg.group} -m 0750 -d ${cfg.rootDirectory}
      '';

      serviceConfig = {
        ExecStart = "${cfg.package.infinoted} --config-file=/var/lib/infinoted/infinoted.conf";
        Group = cfg.group;
        PermissionsStartOnly = true;
        Restart = "always";
        Type = "simple";
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups = lib.optionalAttrs (cfg.group == "infinoted") {
      infinoted = { };
    };

    users.users = lib.optionalAttrs (cfg.user == "infinoted") {
      infinoted = {
        description = "Infinoted user";
        group = cfg.group;
        isSystemUser = true;
      };
    };
  };
}
