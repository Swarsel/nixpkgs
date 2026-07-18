{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.brltty;

  targets = [
    "default.target"
    "multi-user.target"
    "rescue.target"
    "emergency.target"
  ];

  genApiKey = pkgs.writers.writeDash "generate-brlapi-key" ''
    if ! test -f /etc/brlapi.key; then
      echo -n generating brlapi key...
      ${pkgs.brltty}/bin/brltty-genkey -f /etc/brlapi.key
      echo done
    fi
  '';

in
{

  options = {

    services.brltty.enable = lib.mkOption {
      default = false;
      description = "Whether to enable the BRLTTY daemon.";
      type = lib.types.bool;
    };

  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.brltty ];
    services.udev.packages = [ pkgs.brltty ];
    # Install all upstream-provided files
    systemd.packages = [ pkgs.brltty ];
    # Add missing WantedBys (see issue #81138)
    systemd.paths.brltty.wantedBy = targets;
    systemd.paths."brltty@".wantedBy = targets;

    systemd.services."brltty@".serviceConfig = {
      ExecStartPre = "!${genApiKey}";
    };

    systemd.tmpfiles.packages = [ pkgs.brltty ];

    users.groups = {
      brlapi = { };
      brltty = { };
    };

    users.users.brltty = {
      description = "BRLTTY daemon user";
      group = "brltty";
      isSystemUser = true;
    };
  };

}
