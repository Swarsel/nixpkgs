{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.zeyple;
  ini = pkgs.formats.ini { };

  gpgHome = pkgs.runCommand "zeyple-gpg-home" { } ''
    mkdir -p $out
    for file in ${lib.concatStringsSep " " cfg.keys}; do
      ${config.programs.gnupg.package}/bin/gpg --homedir="$out" --import "$file"
    done

    # Remove socket files
    rm -f $out/S.*
  '';
in
{
  options.services.zeyple = {
    enable = lib.mkEnableOption "Zeyple, an utility program to automatically encrypt outgoing emails with GPG";

    group = lib.mkOption {
      default = "zeyple";

      description = ''
        Group to use to run Zeyple.

        ::: {.note}
        If left as the default value this group will automatically be created
        on system activation, otherwise the sysadmin is responsible for
        ensuring the user exists.
        :::
      '';

      type = lib.types.str;
    };

    keys = lib.mkOption {
      description = "List of public key files that will be imported by gpg.";
      type = with lib.types; listOf path;
    };

    rotateLogs = lib.mkOption {
      default = true;
      description = "Whether to enable rotation of log files.";
      type = lib.types.bool;
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        Zeyple configuration. refer to
        <https://github.com/infertux/zeyple/blob/master/zeyple/zeyple.conf.example>
        for details on supported values.
      '';

      type = ini.type;
    };

    user = lib.mkOption {
      default = "zeyple";

      description = ''
        User to run Zeyple as.

        ::: {.note}
        If left as the default value this user will automatically be created
        on system activation, otherwise the sysadmin is responsible for
        ensuring the user exists.
        :::
      '';

      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."zeyple.conf".source = ini.generate "zeyple.conf" cfg.settings;

    services.logrotate = lib.mkIf cfg.rotateLogs {
      enable = true;

      settings.zeyple = {
        compress = true;
        copytruncate = true;
        files = cfg.settings.zeyple.log_file;
        frequency = "weekly";
        rotate = 5;
      };
    };

    services.postfix.extraMasterConf = ''
      zeyple    unix  -       n       n       -       -       pipe
        user=${cfg.user} argv=${pkgs.zeyple}/bin/zeyple ''${recipient}

      localhost:${toString cfg.settings.relay.port} inet  n       -       n       -       10      smtpd
        -o content_filter=
        -o receive_override_options=no_unknown_recipient_checks,no_header_body_checks,no_milters
        -o smtpd_helo_restrictions=
        -o smtpd_client_restrictions=
        -o smtpd_sender_restrictions=
        -o smtpd_recipient_restrictions=permit_mynetworks,reject
        -o mynetworks=127.0.0.0/8,[::1]/128
        -o smtpd_authorized_xforward_hosts=127.0.0.0/8,[::1]/128
    '';

    services.postfix.settings.main.content_filter = "zeyple";

    services.zeyple.settings = {
      gpg = lib.mapAttrs (name: lib.mkDefault) { home = "${gpgHome}"; };

      relay = lib.mapAttrs (name: lib.mkDefault) {
        host = "localhost";
        port = 10026;
      };

      zeyple = lib.mapAttrs (name: lib.mkDefault) {
        force_encrypt = true;
        log_file = "/var/log/zeyple/zeyple.log";
      };
    };

    systemd.tmpfiles.settings."10-zeyple".${cfg.settings.zeyple.log_file}.f = {
      inherit (cfg) user group;
      mode = "0600";
    };

    users.groups = lib.optionalAttrs (cfg.group == "zeyple") { "${cfg.group}" = { }; };

    users.users = lib.optionalAttrs (cfg.user == "zeyple") {
      "${cfg.user}" = {
        group = cfg.group;
        isSystemUser = true;
      };
    };
  };
}
