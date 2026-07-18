{
  config,
  lib,
  pkgs,
  ...
}:
let
  format = pkgs.formats.yaml { };
  cfg = config.services.evdevremapkeys;

in
{
  options.services.evdevremapkeys = {
    enable = lib.mkEnableOption "evdevremapkeys, a daemon to remap events on linux input devices";

    settings = lib.mkOption {
      default = { };

      description = ''
        config.yaml for evdevremapkeys
      '';

      type = format.type;
    };
  };

  config = lib.mkIf cfg.enable {
    boot.kernelModules = [ "uinput" ];

    services.udev.extraRules = ''
      KERNEL=="uinput", MODE="0660", GROUP="input"
    '';

    systemd.services.evdevremapkeys = {
      description = "evdevremapkeys";

      serviceConfig =
        let
          config = format.generate "config.yaml" cfg.settings;
        in
        {
          ExecStart = "${pkgs.evdevremapkeys}/bin/evdevremapkeys --config-file ${config}";
          Group = "evdevremapkeys";
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;
          PrivateNetwork = true;
          PrivateTmp = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectKernelTunables = true;
          ProtectSystem = true;
          Restart = "always";
          StateDirectory = "evdevremapkeys";
          User = "evdevremapkeys";
        };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.evdevremapkeys = { };

    users.users.evdevremapkeys = {
      description = "evdevremapkeys service user";
      extraGroups = [ "input" ];
      group = "evdevremapkeys";
      isSystemUser = true;
    };
  };
}
