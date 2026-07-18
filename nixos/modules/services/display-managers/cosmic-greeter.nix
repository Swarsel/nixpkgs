# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: Lily Foster <lily@lily.flowers>
# Portions of this code are adapted from nixos-cosmic
# https://github.com/lilyinstarlight/nixos-cosmic

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.displayManager.cosmic-greeter;
  cfgAutoLogin = config.services.displayManager.autoLogin;
in

{
  options.services.displayManager.cosmic-greeter = {
    enable = lib.mkEnableOption "COSMIC greeter";
    package = lib.mkPackageOption pkgs "cosmic-greeter" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.cosmic-comp
      pkgs.cosmic-icons
      cfg.package
    ];

    hardware.graphics.enable = true;

    # Required for authentication
    security.pam.services.cosmic-greeter = {
      allowNullPassword = true;
    };

    services.accounts-daemon.enable = true;
    services.dbus.packages = [ cfg.package ];

    services.greetd = {
      enable = true;

      settings = {
        default_session = {
          command = ''${lib.getExe' pkgs.coreutils "env"} XCURSOR_THEME="''${XCURSOR_THEME:-Pop}" ${lib.getExe' cfg.package "cosmic-greeter-start"}'';
          user = "cosmic-greeter";
        };

        initial_session = lib.mkIf (cfgAutoLogin.enable && (cfgAutoLogin.user != null)) {
          command = ''${lib.getExe' pkgs.coreutils "env"} XCURSOR_THEME="''${XCURSOR_THEME:-Pop}" systemd-cat -t cosmic-session ${lib.getExe' pkgs.cosmic-session "start-cosmic"}'';
          user = cfgAutoLogin.user;
        };
      };
    };

    services.libinput.enable = true;

    # Daemon for querying background state and such
    systemd.services.cosmic-greeter-daemon = {
      before = [ "greetd.service" ];

      serviceConfig = {
        BusName = "com.system76.CosmicGreeter";
        ExecStart = lib.getExe' cfg.package "cosmic-greeter-daemon";
        Restart = "on-failure";
        Type = "dbus";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.settings.cosmic-greeter."/run/cosmic-greeter".d = {
      group = "cosmic-greeter";
      mode = "0755";
      user = "cosmic-greeter";
    };

    # The greeter user is hardcoded in `cosmic-greeter`
    users.groups.cosmic-greeter = { };

    users.users.cosmic-greeter = {
      createHome = true;
      description = "COSMIC login greeter user";
      extraGroups = [ "video" ];
      group = "cosmic-greeter";
      home = "/var/lib/cosmic-greeter";
      homeMode = "0750";
      isSystemUser = true;
    };
  };

  meta.teams = [ lib.teams.cosmic ];
}
