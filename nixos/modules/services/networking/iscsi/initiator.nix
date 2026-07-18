{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.openiscsi;
in
{
  options.services.openiscsi = with types; {
    enable = mkEnableOption "the openiscsi iscsi daemon";
    package = mkPackageOption pkgs "openiscsi" { };

    discoverPortal = mkOption {
      default = null;
      description = "Portal to discover targets on";
      type = nullOr str;
    };

    enableAutoLoginOut = mkEnableOption ''
      automatic login and logout of all automatic targets.
      You probably do not want this
    '';

    extraConfig = mkOption {
      default = "";
      description = "Lines to append to default iscsid.conf";
      type = str;
    };

    extraConfigFile = mkOption {
      default = null;

      description = ''
        Append an additional file's contents to /etc/iscsid.conf. Use a non-store path
        and store passwords in this file.
      '';

      type = nullOr str;
    };

    name = mkOption {
      description = "Name of this iscsi initiator";
      example = "iqn.2020-08.org.linux-iscsi.initiatorhost:example";
      type = str;
    };
  };

  config = mkIf cfg.enable {
    boot.kernelModules = [ "iscsi_tcp" ];
    environment.etc."iscsi/initiatorname.iscsi".text = "InitiatorName=${cfg.name}";

    environment.etc."iscsi/iscsid.conf.fragment".source = pkgs.runCommand "iscsid.conf" { } ''
      cat "${cfg.package}/etc/iscsi/iscsid.conf" > $out
      cat << 'EOF' >> $out
      ${cfg.extraConfig}
      ${optionalString cfg.enableAutoLoginOut "node.startup = automatic"}
      EOF
    '';

    environment.systemPackages = [ cfg.package ];
    systemd.packages = [ cfg.package ];

    systemd.services."iscsi" = mkIf cfg.enableAutoLoginOut {
      serviceConfig.ExecStartPre =
        mkIf (cfg.discoverPortal != null)
          "${cfg.package}/bin/iscsiadm --mode discoverydb --type sendtargets --portal ${escapeShellArg cfg.discoverPortal} --discover";

      wantedBy = [ "remote-fs.target" ];
    };

    systemd.services."iscsid" = {
      preStart =
        let
          extraCfgDumper = optionalString (cfg.extraConfigFile != null) ''
            if [ -f "${cfg.extraConfigFile}" ]; then
              printf "\n# The following is from ${cfg.extraConfigFile}:\n"
              cat "${cfg.extraConfigFile}"
            else
              echo "Warning: services.openiscsi.extraConfigFile ${cfg.extraConfigFile} does not exist!" >&2
            fi
          '';
        in
        ''
          (
            cat ${config.environment.etc."iscsi/iscsid.conf.fragment".source}
            ${extraCfgDumper}
          ) > /etc/iscsi/iscsid.conf
        '';

      wantedBy = [ "multi-user.target" ];
    };

    systemd.sockets."iscsid".wantedBy = [ "sockets.target" ];
  };
}
