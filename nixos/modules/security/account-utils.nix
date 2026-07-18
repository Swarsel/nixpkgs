{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.security.account-utils;
in
{
  options.security.account-utils = {
    enable = lib.mkEnableOption "the account-utils implementation of Unix user authentication and management";
    package = lib.mkPackageOption pkgs "account-utils" { };

    extraArgs = lib.mkOption {
      default = [ ];

      description = ''
        List of arguments to pass to the socket activated service executables.
        ::: {.note}
        This is passed to both pwupdd and pwaccessd, which support identical flags.
        :::
      '';

      example = [
        "--debug"
        "-v"
      ];

      type = lib.types.listOf lib.types.nonEmptyStr;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    # use account-utils reimplementation of pam_unix
    security.pam = {
      enableLegacySettings = false;
      pam_unixModulePath = "${cfg.package}/lib/security/pam_unix_ng.so";
    };

    security.pam.services = {
      pwupd-chfn = { };
      pwupd-chsh = { };
      pwupd-passwd = { };
    };

    # covered by account-utils via socket-activated service
    security.wrappers = {
      chsh.enable = false;
      newgidmap.enable = false;
      # shadow suid binaries are no longer necessary, but disabling the entire shadow module is too intrusive
      newuidmap.enable = false;
      passwd.enable = false;
      unix_chkpwd.enable = false; # Not necessary when using pam_unix_ng.so
    };

    systemd = {
      packages = [ cfg.package ];
      services."pwaccessd".environment.PWACCESSD_OPTS = lib.escapeShellArgs cfg.extraArgs;
      services."pwupdd@".environment.PWUPDD_OPTS = lib.escapeShellArgs cfg.extraArgs;
      sockets.newidmapd.wantedBy = [ "sockets.target" ];
      sockets.pwaccessd.wantedBy = [ "sockets.target" ];
      sockets.pwupdd.wantedBy = lib.optional config.users.mutableUsers "sockets.target"; # immutable users do not need password updating
    };
  };
}
