{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.boot.plymouth.tpm2-totp;
in
{
  options.boot.plymouth.tpm2-totp = {
    enable = lib.mkEnableOption "tpm2-totp using Plymouth" // {
      description = "Whether to display a TOTP during boot using tpm2-totp and Plymouth.";
    };

    package = lib.mkPackageOption pkgs "tpm2-totp" { default = "tpm2-totp-with-plymouth"; };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.boot.initrd.systemd.enable;
        message = "boot.plymouth.tpm2-totp is only supported with boot.initrd.systemd.";
      }
    ];

    # Based on https://github.com/tpm2-software/tpm2-totp/blob/9bcfdcbfdd42e0b2e1d7769852009608f889631c/dist/plymouth-tpm2-totp.service.in
    boot.initrd.systemd.services.plymouth-tpm2-totp = {
      after = [
        "plymouth-start.service"
        "tpm2.target"
      ];

      description = "Display a TOTP during boot using Plymouth";
      requires = [ "plymouth-start.service" ];

      serviceConfig = {
        ExecStart = "${cfg.package}/libexec/tpm2-totp/plymouth-tpm2-totp";
        Type = "exec";
      };

      unitConfig.DefaultDependencies = false;
      wantedBy = [ "sysinit.target" ];
    };

    boot.initrd.systemd.storePaths = [
      "${cfg.package}/libexec/tpm2-totp/plymouth-tpm2-totp"
      "${cfg.package}/lib/libtpm2-totp.so.0"
      "${cfg.package}/lib/libtpm2-totp.so.0.0.0"
    ];

    environment.systemPackages = [
      cfg.package
    ];
  };

  meta = {
    doc = ./plymouth-tpm2-totp.md;
    maintainers = with lib.maintainers; [ majiir ];
  };
}
