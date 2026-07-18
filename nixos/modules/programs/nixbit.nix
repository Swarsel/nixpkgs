{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    types
    ;
  cfg = config.programs.nixbit;
in
{
  options.programs.nixbit = {
    enable = mkEnableOption "Nixbit configuration";
    package = mkPackageOption pkgs "nixbit" { };

    forceAutostart = mkEnableOption "" // {
      description = "Force creation of autostart desktop entry when application starts";
    };

    repository = mkOption {
      description = "Git repository URL for Nixbit";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    environment = {
      etc."nixbit.conf".text =
        lib.optionalString (cfg.repository != "") ''
          [Repository]
          Url = ${cfg.repository}
        ''
        + ''
          [Autostart]
          Force = ${if cfg.forceAutostart then "true" else "false"}
        '';

      systemPackages = [ cfg.package ];
    };
  };
}
