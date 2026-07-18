{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.xonotic;

  serverCfg = pkgs.writeText "xonotic-server.cfg" (
    toString cfg.prependConfig
    + "\n"
    + builtins.concatStringsSep "\n" (
      lib.mapAttrsToList (
        key: option:
        let
          escape = s: lib.escape [ "\"" ] s;
          quote = s: "\"${s}\"";

          toValue = x: quote (escape (toString x));

          value = (
            if lib.isList option then
              builtins.concatStringsSep " " (map (x: toValue x) option)
            else
              toValue option
          );
        in
        "${key} ${value}"
      ) cfg.settings
    )
    + "\n"
    + toString cfg.appendConfig
  );
in

{
  options.services.xonotic = {
    enable = lib.mkEnableOption "Xonotic dedicated server";
    package = lib.mkPackageOption pkgs "xonotic-dedicated" { };

    # Still useful even though we're using RFC 42 settings because *some* keys
    # can be repeated.
    appendConfig = lib.mkOption {
      default = null;

      description = ''
        Literal text to insert at the end of `server.cfg`.
      '';

      type = with lib.types; nullOr lines;
    };

    dataDir = lib.mkOption {
      default = "/var/lib/xonotic";

      description = ''
        Data directory.
      '';

      readOnly = true;
      type = lib.types.path;
    };

    openFirewall = lib.mkOption {
      default = false;

      description = ''
        Open the firewall for TCP and UDP on the specified port.
      '';

      type = lib.types.bool;
    };

    # Certain changes need to happen at the beginning of the file.
    prependConfig = lib.mkOption {
      default = null;

      description = ''
        Literal text to insert at the start of `server.cfg`.
      '';

      type = with lib.types; nullOr lines;
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        Generates the `server.cfg` file. Refer to [upstream's example][0] for
        details.

        [0]: https://gitlab.com/xonotic/xonotic/-/blob/master/server/server.cfg
      '';

      type = lib.types.submodule {
        options.hostname = lib.mkOption {
          default = "Xonotic $g_xonoticversion Server";

          description = ''
            The name that will appear in the server list. `$g_xonoticversion`
            gets replaced with the current version.
          '';

          type = lib.types.singleLineStr;
        };

        options.maxplayers = lib.mkOption {
          default = 16;

          description = ''
            Number of player slots on the server, including spectators.
          '';

          type = lib.types.int;
        };

        options.net_address = lib.mkOption {
          default = "0.0.0.0";

          description = ''
            The address Xonotic will listen on.
          '';

          type = lib.types.singleLineStr;
        };

        options.port = lib.mkOption {
          default = 26000;

          description = ''
            The port Xonotic will listen on.
          '';

          type = lib.types.port;
        };

        options.sv_motd = lib.mkOption {
          default = "";

          description = ''
            Text displayed when players join the server.
          '';

          type = lib.types.singleLineStr;
        };

        options.sv_public = lib.mkOption {
          default = 0;

          description = ''
            Controls whether the server will be publicly listed.
          '';

          example = [
            (-1)
            1
          ];

          type = lib.types.int;
        };

        options.sv_termsofservice_url = lib.mkOption {
          default = "";

          description = ''
            URL for the Terms of Service for playing on your server.
          '';

          type = lib.types.singleLineStr;
        };

        freeformType =
          with lib.types;
          let
            scalars = oneOf [
              singleLineStr
              int
              float
            ];
          in
          attrsOf (oneOf [
            scalars
            (nonEmptyListOf scalars)
          ]);
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [
      cfg.settings.port
    ];

    networking.firewall.allowedUDPPorts = lib.mkIf cfg.openFirewall [
      cfg.settings.port
    ];

    systemd.services.xonotic = {
      description = "Xonotic server";

      environment = {
        # Required or else it tries to write the lock file into the nix store
        HOME = cfg.dataDir;
      };

      serviceConfig = {
        DynamicUser = true;
        # Cargo-culted from search results about writing Xonotic systemd units
        ExecReload = "${pkgs.util-linux}/bin/kill -HUP $MAINPID";
        ExecStart = "${cfg.package}/bin/xonotic-dedicated";

        # Symlink the configuration from the nix store to where Xonotic actually
        # looks for it
        ExecStartPre = [
          "${pkgs.coreutils}/bin/mkdir -p ${cfg.dataDir}/.xonotic/data"
          ''
            ${pkgs.coreutils}/bin/ln -sf ${serverCfg} \
              ${cfg.dataDir}/.xonotic/data/server.cfg
          ''
        ];

        Restart = "on-failure";
        RestartSec = 10;
        StateDirectory = "xonotic";
        User = "xonotic";
      };

      unitConfig = {
        StartLimitBurst = 5;
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ CobaltCause ];
}
