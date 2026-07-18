{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.vim;
in
{
  options.programs.vim = {
    enable = lib.mkEnableOption "Vi IMproved, an advanced text editor";
    package = lib.mkPackageOption pkgs "vim" { example = [ "vim-full" ]; };
    defaultEditor = lib.mkEnableOption "vim as the default editor";
  };

  config = lib.mkIf (cfg.enable || cfg.defaultEditor) {
    assertions = [
      {
        assertion = cfg.defaultEditor -> cfg.enable;
        message = "{option}`programs.vim.defaultEditor` requires {option}`programs.vim.enable` to be set to true.";
      }
    ];

    environment = {
      pathsToLink = [ "/share/vim-plugins" ];
      sessionVariables.EDITOR = lib.mkIf cfg.defaultEditor (lib.mkOverride 900 "vim");
      systemPackages = [ cfg.package ];
    };
  };
}
