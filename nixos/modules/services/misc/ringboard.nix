{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.ringboard;
in
{
  options.services.ringboard = {
    wayland.enable = lib.mkEnableOption "Wayland support for Ringboard";
    wayland.package = lib.mkPackageOption pkgs "ringboard-wayland" { };
    x11.enable = lib.mkEnableOption "X11 support for Ringboard";
    x11.package = lib.mkPackageOption pkgs "ringboard" { };
  };

  config = lib.mkIf (cfg.x11.enable || cfg.wayland.enable) {
    environment.systemPackages =
      lib.optionals cfg.x11.enable [ cfg.x11.package ]
      ++ lib.optionals cfg.wayland.enable [ cfg.wayland.package ];

    systemd.user.services.ringboard-listener = {
      after = [
        "ringboard-server.service"
        "graphical-session.target"
      ];

      bindsTo = [ "graphical-session.target" ];
      description = "Ringboard clipboard listener";
      documentation = [ "https://github.com/SUPERCILEX/clipboard-history" ];
      environment.RUST_LOG = "trace";
      requires = [ "ringboard-server.service" ];

      script =
        if cfg.x11.enable && cfg.wayland.enable then
          ''
            if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
              exec '${cfg.wayland.package}'/bin/ringboard-wayland
            else
              exec '${cfg.x11.package}'/bin/ringboard-x11
            fi
          ''
        else if cfg.wayland.enable then
          ''
            exec '${cfg.wayland.package}'/bin/ringboard-wayland
          ''
        else
          ''
            exec '${cfg.x11.package}'/bin/ringboard-x11
          '';

      serviceConfig = {
        Restart = "on-failure";
        Slice = "session-ringboard.slice";
        Type = "exec";
      };

      wantedBy = [ "graphical-session.target" ];
    };

    systemd.user.services.ringboard-server = {
      after = [ "multi-user.target" ];
      description = "Ringboard server";
      documentation = [ "https://github.com/SUPERCILEX/clipboard-history" ];

      serviceConfig = {
        Environment = "RUST_LOG=trace";

        ExecStart = "${
          if cfg.x11.enable then cfg.x11.package else cfg.wayland.package
        }/bin/ringboard-server";

        Restart = "on-failure";
        Slice = "session-ringboard.slice";
        Type = "notify";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.user.slices.session-ringboard = {
      description = "Ringboard clipboard services";
    };
  };
}
