{
  config,
  lib,
  pkgs,
  ...
}:

let
  nncpCfgFile = "/run/nncp.hjson";
  programCfg = config.programs.nncp;
  settingsFormat = pkgs.formats.json { };
  jsonCfgFile = settingsFormat.generate "nncp.json" programCfg.settings;
  pkg = programCfg.package;
in
{
  options.programs.nncp = {

    enable = lib.mkEnableOption "NNCP (Node to Node copy) utilities and configuration";
    package = lib.mkPackageOption pkgs "nncp" { };

    group = lib.mkOption {
      default = "uucp";

      description = ''
        The group under which NNCP files shall be owned.
        Any member of this group may access the secret keys
        of this NNCP node.
      '';

      type = lib.types.str;
    };

    secrets = lib.mkOption {
      description = ''
        A list of paths to NNCP configuration files that should not be
        in the Nix store. These files are layered on top of the values at
        [](#opt-programs.nncp.settings).
      '';

      example = [ "/run/keys/nncp.hjson" ];
      type = with lib.types; listOf str;
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        NNCP configuration, see
        <http://www.nncpgo.org/Configuration.html>.
        At runtime these settings will be overlayed by the contents of
        [](#opt-programs.nncp.secrets) into the file
        `${nncpCfgFile}`. Node keypairs go in
        `secrets`, do not specify them in
        `settings` as they will be leaked into
        `/nix/store`!
      '';

      type = settingsFormat.type;
    };

  };

  config = lib.mkIf programCfg.enable {

    environment = {
      etc."nncp.hjson".source = nncpCfgFile;
      systemPackages = [ pkg ];
    };

    programs.nncp.settings = {
      log = lib.mkDefault "/var/spool/nncp/log";
      spool = lib.mkDefault "/var/spool/nncp";
    };

    systemd.services.nncp-config = {
      description = "Generate NNCP configuration";
      path = [ pkg ];

      script = ''
        umask 127
        rm -f ${nncpCfgFile}
        for f in ${jsonCfgFile} ${toString config.programs.nncp.secrets}
        do
          ${lib.getExe pkgs.hjson-go} -c <"$f"
        done |${lib.getExe pkgs.jq} --slurp 'reduce .[] as $x ({}; . * $x)' >${nncpCfgFile}
        chgrp ${programCfg.group} ${nncpCfgFile}
      '';

      serviceConfig.Type = "oneshot";
      wantedBy = [ "basic.target" ];
    };

    systemd.tmpfiles.rules = [
      "d ${programCfg.settings.spool} 0770 root ${programCfg.group}"
      "f ${programCfg.settings.log} 0770 root ${programCfg.group}"
    ];
  };
}
