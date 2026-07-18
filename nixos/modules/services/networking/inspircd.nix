{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.inspircd;

  configFile = pkgs.writeText "inspircd.conf" cfg.config;

in
{
  options = {
    services.inspircd = {
      config = lib.mkOption {
        description = ''
          Verbatim {file}`inspircd.conf` file.
          For a list of options, consult the
          [InspIRCd documentation](https://docs.inspircd.org/3/configuration/), the
          [Module documentation](https://docs.inspircd.org/3/modules/)
          and the example configuration files distributed
          with `pkgs.inspircd.doc`
        '';

        type = lib.types.lines;
      };

      enable = lib.mkEnableOption "InspIRCd";

      package = lib.mkOption {
        default = pkgs.inspircd;
        defaultText = lib.literalExpression "pkgs.inspircd";

        description = ''
          The InspIRCd package to use. This is mainly useful
          to specify an overridden version of the
          `pkgs.inspircd` dervivation, for
          example if you want to use a more minimal InspIRCd
          distribution with less modules enabled or with
          modules enabled which can't be distributed in binary
          form due to licensing issues.
        '';

        example = lib.literalExpression "pkgs.inspircdMinimal";
        type = lib.types.package;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.inspircd = {
      after = [
        "network.target"
        "network-online.target"
      ];

      description = "InspIRCd - the stable, high-performance and modular Internet Relay Chat Daemon";

      serviceConfig = {
        DynamicUser = true;
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";

        ExecStart = ''
          ${lib.getBin cfg.package}/bin/inspircd --config ${configFile} --nofork --nopid
        '';

        Restart = "on-failure";
        Type = "simple";
      };

      unitConfig.Documentation = "https://docs.inspircd.org";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };

  meta = {
    maintainers = [ lib.maintainers.sternenseemann ];
  };
}
