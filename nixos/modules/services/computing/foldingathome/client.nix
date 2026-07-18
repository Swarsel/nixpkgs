{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.foldingathome;

  args = [
    "--team"
    "${toString cfg.team}"
  ]
  ++ lib.optionals (cfg.user != null) [
    "--user"
    cfg.user
  ]
  ++ cfg.extraArgs;
in
{
  imports = [
    (lib.mkRenamedOptionModule [ "services" "foldingAtHome" ] [ "services" "foldingathome" ])
    (lib.mkRenamedOptionModule
      [ "services" "foldingathome" "nickname" ]
      [ "services" "foldingathome" "user" ]
    )
    (lib.mkRemovedOptionModule [ "services" "foldingathome" "config" ] ''
      Use <literal>services.foldingathome.extraArgs instead<literal>
    '')
  ];

  options.services.foldingathome = {
    enable = lib.mkEnableOption "Folding@home client";
    package = lib.mkPackageOption pkgs "fahclient" { };

    daemonNiceLevel = lib.mkOption {
      default = 0;

      description = ''
        Daemon process priority for FAHClient.
        0 is the default Unix process priority, 19 is the lowest.
      '';

      type = lib.types.ints.between (-20) 19;
    };

    extraArgs = lib.mkOption {
      default = [ ];

      description = ''
        Extra startup options for the FAHClient. Run
        `fah-client --help` to find all the available options.
      '';

      type = lib.types.listOf lib.types.str;
    };

    team = lib.mkOption {
      default = 236565;

      description = ''
        The team ID associated with the reported computation results. This
        will be used in the ranking statistics.

        By default, use the NixOS folding@home team ID is being used.
      '';

      type = lib.types.int;
    };

    user = lib.mkOption {
      default = null;

      description = ''
        The user associated with the reported computation results. This will
        be used in the ranking statistics.
      '';

      type = lib.types.nullOr lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.foldingathome = {
      after = [ "network.target" ];
      description = "Folding@home client";

      script = ''
        exec ${lib.getExe cfg.package} ${lib.escapeShellArgs args}
      '';

      serviceConfig = {
        DynamicUser = true;
        Nice = cfg.daemonNiceLevel;
        StateDirectory = "foldingathome";
        WorkingDirectory = "%S/foldingathome";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta = {
    maintainers = with lib.maintainers; [ zimbatm ];
  };
}
