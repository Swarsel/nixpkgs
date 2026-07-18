{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.comma;
in
{
  options.programs.comma = {
    enable = lib.mkEnableOption "comma";
    package = lib.mkPackageOption pkgs "comma" { };

    enableBashIntegration = lib.mkEnableOption "comma command-not-found handler for bash" // {
      default = true;
    };

    enableFishIntegration = lib.mkEnableOption "comma command-not-found handler for fish" // {
      default = true;
    };

    enableZshIntegration = lib.mkEnableOption "comma command-not-found handler for zsh" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    programs = {
      bash.interactiveShellInit = lib.mkIf cfg.enableBashIntegration ''
        source ${cfg.package}/share/comma/command-not-found.sh
      '';

      # Disable *other* command-not-found handlers
      command-not-found.enable = lib.mkIf (
        cfg.enableBashIntegration || cfg.enableZshIntegration || cfg.enableFishIntegration
      ) (lib.mkDefault false);

      fish.interactiveShellInit = ''
        source ${cfg.package}/share/comma/command-not-found.fish
      '';

      nix-index = {
        enableBashIntegration = lib.mkIf (cfg.enableBashIntegration) (lib.mkDefault false);
        enableFishIntegration = lib.mkIf (cfg.enableFishIntegration) (lib.mkDefault false);
        enableZshIntegration = lib.mkIf (cfg.enableZshIntegration) (lib.mkDefault false);
      };

      zsh.interactiveShellInit = lib.mkIf cfg.enableZshIntegration ''
        source ${cfg.package}/share/comma/command-not-found.sh
      '';
    };
  };

  meta.maintainers = with lib.maintainers; [ pandapip1 ];
}
