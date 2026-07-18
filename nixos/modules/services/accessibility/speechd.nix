{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.speechd;
  inherit (lib)
    mapAttrs'
    mkEnableOption
    mkIf
    mkPackageOption
    mkOption
    ;
in
{
  options.services.speechd = {
    config = mkOption {
      default = null;

      description = ''
        System wide configuration file for Speech Dispatcher. This will be used if no user configuration file is found.
      '';

      example = ''
        AddModule "module_name" "module_binary" "module_config"
      '';

      type = with lib.types; nullOr lines;
    };

    # FIXME: figure out how to deprecate this EXTREMELY CAREFULLY
    # default guessed conservatively in ../misc/graphical-desktop.nix
    enable = mkEnableOption "speech-dispatcher speech synthesizer daemon";
    package = mkPackageOption pkgs "speechd" { };

    clients = mkOption {
      default = { };

      description = ''
        Client specific configuration.
      '';

      example = {
        emacs = ''
          BeginClient "emacs:*"
          # Example:
          #   DefaultPunctuationMode "some"
          EndClient
        '';
      };

      type = with lib.types; submodule { freeformType = attrsOf lines; };
    };

    modules = mkOption {
      default = { };

      description = ''
        Configuration files of output modules.
      '';

      example = {
        generic-epos = ''
          AddVoice        "cs"  "male1"   "kadlec"
          AddVoice        "sk"  "male1"   "bob"
        '';
      };

      type = with lib.types; submodule { freeformType = attrsOf lines; };
    };
  };

  config = mkIf cfg.enable {
    environment = {
      etc =
        if cfg.config == null then
          { speech-dispatcher.source = "${cfg.package}/etc/speech-dispatcher"; }
        else
          {
            "speech-dispatcher/speechd.conf".text = cfg.config;
          }
          // (mapAttrs' (name: value: {
            name = "speech-dispatcher/modules/${name}.conf";
            value.text = value;
          }) cfg.modules)
          // (mapAttrs' (name: value: {
            name = "speech-dispatcher/clients/${name}.conf";
            value.text = value;
          }) cfg.clients);

      systemPackages = [ cfg.package ];
    };

    systemd.packages = [ cfg.package ];
    # have to set `wantedBy` since `systemd.packages` ignores `[Install]`
    systemd.user.sockets.speech-dispatcher.wantedBy = [ "sockets.target" ];
  };
}
