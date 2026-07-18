{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.teeworlds;
  register = cfg.register;

  bool = b: if b != null && b then "1" else "0";
  optionalSetting = s: setting: lib.optionalString (s != null) "${setting} ${s}";
  lookup =
    attrs: key: default:
    if attrs ? key then attrs."${key}" else default;

  inactivePenaltyOptions = {
    "kick" = "3";
    "spectator" = "1";
    "spectator/kick" = "2";
  };
  skillLevelOptions = {
    "casual" = "0";
    "competitive" = "2";
    "normal" = "1";
  };
  tournamentModeOptions = {
    "enable" = "1";
    "disable" = "0";
    "restrictSpectators" = "2";
  };

  teeworldsConf = pkgs.writeText "teeworlds.cfg" ''
    sv_port ${toString cfg.port}
    sv_register ${bool cfg.register}
    sv_name ${cfg.name}
    ${optionalSetting cfg.motd "sv_motd"}
    ${optionalSetting cfg.password "password"}
    ${optionalSetting cfg.rconPassword "sv_rcon_password"}

    ${optionalSetting cfg.server.bindAddr "bindaddr"}
    ${optionalSetting cfg.server.hostName "sv_hostname"}
    sv_high_bandwidth ${bool cfg.server.enableHighBandwidth}
    sv_inactivekick ${lookup inactivePenaltyOptions cfg.server.inactivePenalty "spectator/kick"}
    sv_inactivekick_spec ${bool cfg.server.kickInactiveSpectators}
    sv_inactivekick_time ${toString cfg.server.inactiveTime}
    sv_max_clients ${toString cfg.server.maxClients}
    sv_max_clients_per_ip ${toString cfg.server.maxClientsPerIP}
    sv_skill_level ${lookup skillLevelOptions cfg.server.skillLevel "normal"}
    sv_spamprotection ${bool cfg.server.enableSpamProtection}

    sv_gametype ${cfg.game.gameType}
    sv_map ${cfg.game.map}
    sv_match_swap ${bool cfg.game.swapTeams}
    sv_player_ready_mode ${bool cfg.game.enableReadyMode}
    sv_player_slots ${toString cfg.game.playerSlots}
    sv_powerups ${bool cfg.game.enablePowerups}
    sv_scorelimit ${toString cfg.game.scoreLimit}
    sv_strict_spectate_mode ${bool cfg.game.restrictSpectators}
    sv_teamdamage ${bool cfg.game.enableTeamDamage}
    sv_timelimit ${toString cfg.game.timeLimit}
    sv_tournament_mode ${lookup tournamentModeOptions cfg.server.tournamentMode "disable"}
    sv_vote_kick ${bool cfg.game.enableVoteKick}
    sv_vote_kick_bantime ${toString cfg.game.voteKickBanTime}
    sv_vote_kick_min ${toString cfg.game.voteKickMinimumPlayers}

    ${optionalSetting cfg.server.bindAddr "bindaddr"}
    ${optionalSetting cfg.server.hostName "sv_hostname"}
    sv_high_bandwidth ${bool cfg.server.enableHighBandwidth}
    sv_inactivekick ${lookup inactivePenaltyOptions cfg.server.inactivePenalty "spectator/kick"}
    sv_inactivekick_spec ${bool cfg.server.kickInactiveSpectators}
    sv_inactivekick_time ${toString cfg.server.inactiveTime}
    sv_max_clients ${toString cfg.server.maxClients}
    sv_max_clients_per_ip ${toString cfg.server.maxClientsPerIP}
    sv_skill_level ${lookup skillLevelOptions cfg.server.skillLevel "normal"}
    sv_spamprotection ${bool cfg.server.enableSpamProtection}

    sv_gametype ${cfg.game.gameType}
    sv_map ${cfg.game.map}
    sv_match_swap ${bool cfg.game.swapTeams}
    sv_player_ready_mode ${bool cfg.game.enableReadyMode}
    sv_player_slots ${toString cfg.game.playerSlots}
    sv_powerups ${bool cfg.game.enablePowerups}
    sv_scorelimit ${toString cfg.game.scoreLimit}
    sv_strict_spectate_mode ${bool cfg.game.restrictSpectators}
    sv_teamdamage ${bool cfg.game.enableTeamDamage}
    sv_timelimit ${toString cfg.game.timeLimit}
    sv_tournament_mode ${lookup tournamentModeOptions cfg.server.tournamentMode "disable"}
    sv_vote_kick ${bool cfg.game.enableVoteKick}
    sv_vote_kick_bantime ${toString cfg.game.voteKickBanTime}
    sv_vote_kick_min ${toString cfg.game.voteKickMinimumPlayers}

    ${lib.concatStringsSep "\n" cfg.extraOptions}
  '';

in
{
  options = {
    services.teeworlds = {
      enable = lib.mkEnableOption "Teeworlds Server";
      package = lib.mkPackageOption pkgs "teeworlds-server" { };

      environmentFile = lib.mkOption {
        default = null;

        description = ''
          Environment file as defined in {manpage}`systemd.exec(5)`.

          Secrets may be passed to the service without adding them to the world-readable
          Nix store, by specifying placeholder variables as the option value in Nix and
          setting these variables accordingly in the environment file.

          ```
            # snippet of teeworlds-related config
            services.teeworlds.password = "$TEEWORLDS_PASSWORD";
          ```

          ```
            # content of the environment file
            TEEWORLDS_PASSWORD=verysecretpassword
          ```

          Note that this file needs to be available on the host on which
          `teeworlds` is running.
        '';

        example = "/var/lib/teeworlds/teeworlds.env";
        type = lib.types.nullOr lib.types.path;
      };

      extraOptions = lib.mkOption {
        default = [ ];

        description = ''
          Extra configuration lines for the {file}`teeworlds.cfg`. See [Teeworlds Documentation](https://www.teeworlds.com/?page=docs&wiki=server_settings).
        '';

        example = [
          "sv_map dm1"
          "sv_gametype dm"
        ];

        type = lib.types.listOf lib.types.str;
      };

      game = {
        enablePowerups = lib.mkOption {
          default = true;

          description = ''
            Whether to allow powerups such as the ninja.
          '';

          type = lib.types.bool;
        };

        enableReadyMode = lib.mkOption {
          default = false;

          description = ''
            Whether to enable "ready mode"; where players can pause/unpause the game
            and start the game in warmup, using their ready state.
          '';

          type = lib.types.bool;
        };

        enableTeamDamage = lib.mkOption {
          default = false;

          description = ''
            Whether to enable team damage; whether to allow team mates to inflict damage on one another.
          '';

          type = lib.types.bool;
        };

        enableVoteKick = lib.mkOption {
          default = true;

          description = ''
            Whether to enable voting to kick players.
          '';

          type = lib.types.bool;
        };

        gameType = lib.mkOption {
          default = "dm";

          description = ''
            The game type to use on the server.

            The default gametypes are `dm`, `tdm`, `ctf`, `lms`, and `lts`.
          '';

          example = "ctf";
          type = lib.types.str;
        };

        map = lib.mkOption {
          default = "dm1";

          description = ''
            The map to use on the server.
          '';

          example = "ctf5";
          type = lib.types.str;
        };

        playerSlots = lib.mkOption {
          default = 8;

          description = ''
            The amount of slots to reserve for players (as opposed to spectators).
          '';

          type = lib.types.ints.unsigned;
        };

        restrictSpectators = lib.mkOption {
          default = false;

          description = ''
            Whether to restrict access to information such as health, ammo and armour in spectator mode.
          '';

          type = lib.types.bool;
        };

        scoreLimit = lib.mkOption {
          default = 20;

          description = ''
            The score limit needed to win a round.
          '';

          example = 400;
          type = lib.types.ints.unsigned;
        };

        swapTeams = lib.mkOption {
          default = true;

          description = ''
            Whether to swap teams each round.
          '';

          type = lib.types.bool;
        };

        timeLimit = lib.mkOption {
          default = 0;

          description = ''
            Time limit of the game. In cases of equal points, there will be sudden death.
            Setting this to 0 disables a time limit.
          '';

          type = lib.types.ints.unsigned;
        };

        tournamentMode = lib.mkOption {
          default = "disable";

          description = ''
            Whether to enable tournament mode. In tournament mode, players join as spectators.
            If this is set to `restrictSpectators`, tournament mode is enabled but spectator chat is restricted.
          '';

          type = lib.types.enum [
            "disable"
            "enable"
            "restrictSpectators"
          ];
        };

        voteKickBanTime = lib.mkOption {
          default = 5;

          description = ''
            The amount of minutes that a player is banned for if they get kicked by a vote.
          '';

          type = lib.types.ints.unsigned;
        };

        voteKickMinimumPlayers = lib.mkOption {
          default = 5;

          description = ''
            The minimum amount of players required to start a kick vote.
          '';

          type = lib.types.ints.unsigned;
        };
      };

      motd = lib.mkOption {
        default = null;

        description = ''
          The server's message of the day text.
        '';

        type = lib.types.nullOr lib.types.str;
      };

      name = lib.mkOption {
        default = "unnamed server";

        description = ''
          Name of the server.
        '';

        type = lib.types.str;
      };

      openPorts = lib.mkOption {
        default = false;
        description = "Whether to open firewall ports for Teeworlds.";
        type = lib.types.bool;
      };

      password = lib.mkOption {
        default = null;

        description = ''
          Password to connect to the server.
        '';

        type = lib.types.nullOr lib.types.str;
      };

      port = lib.mkOption {
        default = 8303;

        description = ''
          Port the server will listen on.
        '';

        type = lib.types.port;
      };

      rconPassword = lib.mkOption {
        default = null;

        description = ''
          Password to access the remote console. If not set, a randomly generated one is displayed in the server log.
        '';

        type = lib.types.nullOr lib.types.str;
      };

      register = lib.mkOption {
        default = false;

        description = ''
          Whether the server registers as a public server in the global server list. This is disabled by default for privacy reasons.
        '';

        example = true;
        type = lib.types.bool;
      };

      server = {
        bindAddr = lib.mkOption {
          default = null;

          description = ''
            The address the server will bind to.
          '';

          type = lib.types.nullOr lib.types.str;
        };

        enableHighBandwidth = lib.mkOption {
          default = false;

          description = ''
            Whether to enable high bandwidth mode on LAN servers. This will double the amount of bandwidth required for running the server.
          '';

          type = lib.types.bool;
        };

        enableSpamProtection = lib.mkOption {
          default = true;

          description = ''
            Whether to enable chat spam protection.
          '';

          type = lib.types.bool;
        };

        hostName = lib.mkOption {
          default = null;

          description = ''
            Hostname for the server.
          '';

          type = lib.types.nullOr lib.types.str;
        };

        inactivePenalty = lib.mkOption {
          default = "spectator/kick";

          description = ''
            Specify what to do when a client goes inactive (see [](#opt-services.teeworlds.server.inactiveTime)).

            - `spectator`: send the client into spectator mode

            - `spectator/kick`: send the client into a free spectator slot, otherwise kick the client

            - `kick`: kick the client
          '';

          example = "spectator";

          type = lib.types.enum [
            "spectator"
            "spectator/kick"
            "kick"
          ];
        };

        inactiveTime = lib.mkOption {
          default = 3;

          description = ''
            The amount of minutes a client has to idle before it is considered inactive.
          '';

          type = lib.types.ints.unsigned;
        };

        kickInactiveSpectators = lib.mkOption {
          default = false;

          description = ''
            Whether to kick inactive spectators.
          '';

          type = lib.types.bool;
        };

        maxClients = lib.mkOption {
          default = 12;

          description = ''
            The maximum amount of clients that can be connected to the server at the same time.
          '';

          type = lib.types.ints.unsigned;
        };

        maxClientsPerIP = lib.mkOption {
          default = 12;

          description = ''
            The maximum amount of clients with the same IP address that can be connected to the server at the same time.
          '';

          type = lib.types.ints.unsigned;
        };

        skillLevel = lib.mkOption {
          default = "normal";

          description = ''
            The skill level shown in the server browser.
          '';

          type = lib.types.enum [
            "casual"
            "normal"
            "competitive"
          ];
        };
      };

    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = lib.mkIf cfg.openPorts {
      allowedUDPPorts = [ cfg.port ];
    };

    systemd.services.teeworlds = {
      after = [ "network.target" ];
      description = "Teeworlds Server";

      serviceConfig = {
        # Hardening
        CapabilityBoundingSet = false;
        DynamicUser = true;
        EnvironmentFile = lib.mkIf (cfg.environmentFile != null) [ cfg.environmentFile ];
        ExecStart = "${lib.getExe cfg.package} -f /run/teeworlds/teeworlds.yaml";

        ExecStartPre = ''
          ${pkgs.envsubst}/bin/envsubst \
            -i ${teeworldsConf} \
            -o /run/teeworlds/teeworlds.yaml
        '';

        PrivateDevices = true;
        PrivateUsers = true;
        ProtectHome = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RuntimeDirectory = "teeworlds";
        RuntimeDirectoryMode = "0700";
        SystemCallArchitectures = "native";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
