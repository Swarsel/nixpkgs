{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.jai-jail;

in
{
  options.programs.jai-jail = {
    enable = lib.mkEnableOption "jai, a sandbox for AI agents";

    package = lib.mkOption {
      default = pkgs.jai-jail;
      defaultText = lib.literalExpression "pkgs.jai-jail";
      description = "The jai package to use.";
      type = lib.types.package;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    security.wrappers.jai = {
      group = "root";
      owner = "root";
      setuid = true;
      source = "${cfg.package}/bin/jai";
    };

    users.groups.jai = { };

    users.users.jai = {
      description = "JAI sandbox untrusted user";
      group = "jai";
      home = "/";
      isSystemUser = true;
    };
  };

  meta.maintainers = with lib.maintainers; [ agentelement ];
}
