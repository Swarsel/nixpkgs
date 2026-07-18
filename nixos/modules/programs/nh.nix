{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.nh;
in
{
  options.programs.nh = {
    enable = lib.mkEnableOption "nh, yet another Nix CLI helper";
    package = lib.mkPackageOption pkgs "nh" { };

    clean = {
      enable = lib.mkEnableOption "periodic garbage collection with nh clean all";

      dates = lib.mkOption {
        default = "weekly";

        description = ''
          How often cleanup is performed. Passed to systemd.time

          The format is described in
          {manpage}`systemd.time(7)`.
        '';

        type = lib.types.singleLineStr;
      };

      extraArgs = lib.mkOption {
        default = "";

        description = ''
          Options given to nh clean when the service is run automatically.

          See `nh clean all --help` for more information.
        '';

        example = "--keep 5 --keep-since 3d";
        type = lib.types.singleLineStr;
      };
    };

    flake = lib.mkOption {
      default = null;

      description = ''
        The string that will be used for the `NH_FLAKE` environment variable.

        `NH_FLAKE` is used by nh as the default flake for performing actions, such as
        `nh os switch`. This behaviour can be overriden per-command with environment
        variables that will take priority.

        - `NH_OS_FLAKE`: will take priority for `nh os` commands.
        - `NH_HOME_FLAKE`: will take priority for `nh home` commands.
        - `NH_DARWIN_FLAKE`: will take priority for `nh darwin` commands.

        The formerly valid `FLAKE` is now deprecated by nh, and will cause hard errors
        in future releases if `NH_FLAKE` is not set.
      '';

      type = lib.types.nullOr lib.types.str;
    };
  };

  config = {
    assertions = [
      {
        assertion = (cfg.flake != null) -> !(lib.hasSuffix ".nix" cfg.flake);
        message = "nh.flake must be a directory, not a nix file";
      }
    ];

    environment = lib.mkIf cfg.enable {
      systemPackages = [ cfg.package ];

      variables = lib.mkIf (cfg.flake != null) {
        NH_FLAKE = cfg.flake;
      };
    };

    systemd = lib.mkIf cfg.clean.enable {
      services.nh-clean = {
        after = [ "multi-user.target" ];
        description = "Nh clean";
        path = [ config.nix.package ];
        script = "exec ${lib.getExe cfg.package} clean all ${cfg.clean.extraArgs}";
        serviceConfig.Type = "oneshot";
        startAt = cfg.clean.dates;
      };

      timers.nh-clean = {
        timerConfig = {
          Persistent = true;
        };
      };
    };

    warnings =
      if (!(cfg.clean.enable -> !config.nix.gc.automatic)) then
        [
          "programs.nh.clean.enable and nix.gc.automatic are both enabled. Please use one or the other to avoid conflict."
        ]
      else
        [ ];
  };

  meta.maintainers = with lib.maintainers; [
    NotAShelf
    mdaniels5757
    viperML
    faukah
  ];
}
