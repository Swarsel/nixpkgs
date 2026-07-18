{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.ferm;

  configFile = pkgs.stdenv.mkDerivation {
    buildCommand = ''
      echo -n "$text" > $out
      ${cfg.package}/bin/ferm --noexec $out
    '';

    name = "ferm.conf";
    preferLocalBuild = true;
    text = cfg.config;
  };
in
{
  options = {
    services.ferm = {
      config = lib.mkOption {
        default = "";
        defaultText = lib.literalMD "empty firewall, allows any traffic";
        description = "Verbatim ferm.conf configuration.";
        type = lib.types.lines;
      };

      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to enable Ferm Firewall.
          *Warning*: Enabling this service WILL disable the existing NixOS
          firewall! Default firewall rules provided by packages are not
          considered at the moment.
        '';

        type = lib.types.bool;
      };

      package = lib.mkPackageOption pkgs "ferm" { };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.ferm = {
      after = [ "ipset.target" ];
      before = [ "network-pre.target" ];
      description = "Ferm Firewall";
      reloadIfChanged = true;

      serviceConfig = {
        ExecReload = "${cfg.package}/bin/ferm ${configFile}";
        ExecStart = "${cfg.package}/bin/ferm ${configFile}";
        ExecStop = "${cfg.package}/bin/ferm -F ${configFile}";
        RemainAfterExit = "yes";
        Type = "oneshot";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-pre.target" ];
    };

    systemd.services.firewall.enable = false;
  };
}
