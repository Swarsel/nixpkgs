{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.msmtp;

in
{
  options = {
    programs.msmtp = {
      enable = lib.mkEnableOption "msmtp - an SMTP client";
      package = lib.mkPackageOption pkgs "msmtp" { };

      accounts = lib.mkOption {
        default = { };

        description = ''
          Named accounts and their respective configurations.
          The special name "default" allows a default account to be defined.
          See {manpage}`msmtp(1)` for the available options.

          Use `programs.msmtp.extraConfig` instead of this attribute set-based
          option if ordered account inheritance is needed.

          It is advised to use the `passwordeval` setting to read the password
          from a secret file to avoid having it written in the world-readable
          nix store. The password file must end with a newline (`\n`).
        '';

        example = {
          "default" = {
            auth = true;
            host = "smtp.example";
            passwordeval = "cat /secrets/password.txt";
            user = "someone";
          };
        };

        type = with lib.types; attrsOf attrs;
      };

      defaults = lib.mkOption {
        default = { };

        description = ''
          Default values applied to all accounts.
          See {manpage}`msmtp(1)` for the available options.
        '';

        example = {
          aliases = "/etc/aliases";
          port = 587;
          tls = true;
        };

        type = lib.types.attrs;
      };

      extraConfig = lib.mkOption {
        default = "";

        description = ''
          Extra lines to add to the msmtp configuration verbatim.
          See {manpage}`msmtp(1)` for the syntax and available options.
        '';

        type = lib.types.lines;
      };

      setSendmail = lib.mkOption {
        default = true;

        description = ''
          Whether to set the system sendmail to msmtp's.
        '';

        type = lib.types.bool;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."msmtprc".text =
      let
        mkValueString =
          v:
          if v == true then
            "on"
          else if v == false then
            "off"
          else
            lib.generators.mkValueStringDefault { } v;
        mkKeyValueString = k: v: "${k} ${mkValueString v}";
        mkInnerSectionString =
          attrs: builtins.concatStringsSep "\n" (lib.mapAttrsToList mkKeyValueString attrs);
        mkAccountString = name: attrs: ''
          account ${name}
          ${mkInnerSectionString attrs}
        '';
      in
      ''
        defaults
        ${mkInnerSectionString cfg.defaults}

        ${builtins.concatStringsSep "\n" (lib.mapAttrsToList mkAccountString cfg.accounts)}

        ${cfg.extraConfig}
      '';

    environment.systemPackages = [ cfg.package ];

    services.mail.sendmailSetuidWrapper = lib.mkIf cfg.setSendmail {
      group = "root";
      owner = "root";
      program = "sendmail";
      setgid = false;
      setuid = false;
      source = "${cfg.package}/bin/sendmail";
    };
  };

  meta.maintainers = with lib.maintainers; [ euxane ];
}
