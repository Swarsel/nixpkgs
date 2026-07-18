{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.nano;
in

{
  options = {
    programs.nano = {
      enable = lib.mkEnableOption "nano, a small user-friendly console text editor" // {
        default = true;
      };

      package = lib.mkPackageOption pkgs "nano" { };

      nanorc = lib.mkOption {
        default = "";

        description = ''
          The system-wide nano configuration.
          See {manpage}`nanorc(5)`.
        '';

        example = ''
          set nowrap
          set tabstospaces
          set tabsize 2
        '';

        type = lib.types.lines;
      };

      syntaxHighlight = lib.mkOption {
        default = true;
        description = "Whether to enable syntax highlight for various languages.";
        type = lib.types.bool;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment = {
      etc.nanorc.text =
        (lib.optionalString cfg.syntaxHighlight ''
          # load syntax highlighting files
          include "${cfg.package}/share/nano/*.nanorc"
          include "${cfg.package}/share/nano/extra/*.nanorc"
        '')
        + cfg.nanorc;

      pathsToLink = [ "/share/nano" ];
      systemPackages = [ cfg.package ];
    };
  };
}
