{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.xserver.windowManager.exwm;
  loadScript = pkgs.writeText "emacs-exwm-load" ''
    ${cfg.loadScript}
  '';
  packages = epkgs: cfg.extraPackages epkgs ++ [ epkgs.exwm ];
  exwm-emacs = cfg.package.pkgs.withPackages packages;
in
{

  imports = [
    (mkRemovedOptionModule [ "services" "xserver" "windowManager" "exwm" "enableDefaultConfig" ]
      "The upstream EXWM project no longer provides a default configuration, instead copy (parts of) exwm-config.el to your local config."
    )
  ];

  options = {
    services.xserver.windowManager.exwm = {
      enable = mkEnableOption "exwm";

      package = mkPackageOption pkgs "Emacs" {
        default = "emacs";
        example = [ "emacs-gtk" ];
      };

      extraPackages = mkOption {
        default = epkgs: [ ];
        defaultText = literalExpression "epkgs: []";

        description = ''
          Extra packages available to Emacs. The value must be a
          function which receives the attrset defined in
          {var}`emacs.pkgs` as the sole argument.
        '';

        example = literalExpression ''
          epkgs: [
            epkgs.emms
            epkgs.magit
            epkgs.proof-general
          ]
        '';

        type = types.functionTo (types.listOf types.package);
      };

      loadScript = mkOption {
        default = "(require 'exwm)";

        description = ''
          Emacs lisp code to be run after loading the user's init
          file.
        '';

        example = ''
          (require 'exwm)
          (exwm-enable)
        '';

        type = types.lines;
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ exwm-emacs ];

    services.xserver.windowManager.session = singleton {
      name = "exwm";

      start = ''
        ${exwm-emacs}/bin/emacs -l ${loadScript}
      '';
    };
  };
}
