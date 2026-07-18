{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.autojump;
  prg = config.programs;
in
{
  options = {
    programs.autojump = {

      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to enable autojump.
        '';

        type = lib.types.bool;
      };
    };
  };

  ###### implementation

  config = lib.mkIf cfg.enable {
    environment.pathsToLink = [ "/share/autojump" ];
    environment.systemPackages = [ pkgs.autojump ];
    programs.bash.interactiveShellInit = "source ${pkgs.autojump}/share/autojump/autojump.bash";
    programs.fish.interactiveShellInit = lib.mkIf prg.fish.enable "source ${pkgs.autojump}/share/autojump/autojump.fish";
    programs.zsh.interactiveShellInit = lib.mkIf prg.zsh.enable "source ${pkgs.autojump}/share/autojump/autojump.zsh";
  };
}
