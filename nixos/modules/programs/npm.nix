{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.npm;
in

{
  ###### interface

  options = {
    programs.npm = {
      enable = lib.mkEnableOption "{command}`npm` global config";
      package = lib.mkPackageOption pkgs "nodejs" { };

      npmrc = lib.mkOption {
        default = ''
          prefix = ''${HOME}/.npm
        '';

        description = ''
          The system-wide npm configuration.
          See <https://docs.npmjs.com/misc/config>.
        '';

        example = ''
          prefix = ''${HOME}/.npm
          https-proxy=proxy.example.com
          init-license=MIT
          init-author-url=https://www.npmjs.com/
          color=true
        '';

        type = lib.types.lines;
      };
    };
  };

  ###### implementation

  config = lib.mkIf cfg.enable {
    environment.etc.npmrc.text = cfg.npmrc;
    environment.systemPackages = [ cfg.package ];
    environment.variables.NPM_CONFIG_GLOBALCONFIG = "/etc/npmrc";
  };

}
