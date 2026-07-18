{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.ngircd;

  configFile = pkgs.stdenv.mkDerivation {
    buildCommand = ''
      echo -n "$text" > $out
      ${cfg.package}/sbin/ngircd --config $out --configtest
    '';

    name = "ngircd.conf";
    preferLocalBuild = true;
    text = cfg.config;
  };
in
{
  options = {
    services.ngircd = {
      config = mkOption {
        description = "The ngircd configuration (see {manpage}`ngircd.conf(5)`).";
        type = types.lines;
      };

      enable = mkEnableOption "the ngircd IRC server";
      package = mkPackageOption pkgs "ngircd" { };
    };
  };

  config = mkIf cfg.enable {
    #!!! TODO: Use ExecReload (see https://github.com/NixOS/nixpkgs/issues/1988)
    systemd.services.ngircd = {
      description = "The ngircd IRC server";
      serviceConfig.ExecStart = "${cfg.package}/sbin/ngircd --config ${configFile} --nodaemon";
      serviceConfig.User = "ngircd";
      wantedBy = [ "multi-user.target" ];
    };

    users.groups.ngircd = { };

    users.users.ngircd = {
      description = "ngircd user.";
      group = "ngircd";
      isSystemUser = true;
    };

  };
}
