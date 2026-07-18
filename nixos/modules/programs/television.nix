{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.options) mkEnableOption mkPackageOption;
  inherit (lib.modules) mkIf;

  cfg = config.programs.television;
in
{
  options.programs.television = {
    enable = mkEnableOption "Blazingly fast general purpose fuzzy finder TUI";
    package = mkPackageOption pkgs "television" { };
    enableBashIntegration = mkEnableOption "Bash integration";
    enableFishIntegration = mkEnableOption "Fish integration";
    enableZshIntegration = mkEnableOption "Zsh integration";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    programs = {
      bash.interactiveShellInit = mkIf cfg.enableBashIntegration ''
        source ${cfg.package}/share/television/completion.bash
      '';

      fish.interactiveShellInit = mkIf cfg.enableFishIntegration ''
        source ${cfg.package}/share/television/completion.fish
      '';

      zsh.interactiveShellInit = mkIf cfg.enableZshIntegration ''
        source ${cfg.package}/share/television/completion.zsh
      '';
    };

  };

  meta.maintainers = with lib.maintainers; [ pbek ];
}
