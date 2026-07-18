{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.riemann-tools;

  riemannHost = "${cfg.riemannHost}";

  healthLauncher = pkgs.writeScriptBin "riemann-health" ''
    #!/bin/sh
    exec ${pkgs.riemann-tools}/bin/riemann-health ${builtins.concatStringsSep " " cfg.extraArgs} --host ${riemannHost}
  '';

in
{

  options = {

    services.riemann-tools = {
      enableHealth = lib.mkOption {
        default = false;

        description = ''
          Enable the riemann-health daemon.
        '';

        type = lib.types.bool;
      };

      extraArgs = lib.mkOption {
        default = [ ];

        description = ''
          A list of commandline-switches forwarded to a riemann-tool.
          See for example `riemann-health --help` for available options.
        '';

        example = [
          "-p 5555"
          "--timeout=30"
          "--attribute=myattribute=42"
        ];

        type = lib.types.listOf lib.types.str;
      };

      riemannHost = lib.mkOption {
        default = "127.0.0.1";

        description = ''
          Address of the host riemann node. Defaults to localhost.
        '';

        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enableHealth {

    systemd.services.riemann-health = {
      path = [ pkgs.procps ];

      serviceConfig = {
        ExecStart = "${healthLauncher}/bin/riemann-health";
        User = "riemanntools";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.riemanntools.gid = config.ids.gids.riemanntools;

    users.users.riemanntools = {
      description = "riemann-tools daemon user";
      group = "riemanntools";
      uid = config.ids.uids.riemanntools;
    };

  };

}
