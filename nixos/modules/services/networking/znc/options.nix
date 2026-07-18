{ config, lib, ... }:

with lib;

let

  cfg = config.services.znc;

  networkOpts = {
    options = {

      channels = mkOption {
        default = [ ];

        description = ''
          IRC channels to join.
        '';

        example = [ "nixos" ];
        type = types.listOf types.str;
      };

      extraConf = mkOption {
        default = "";

        description = ''
          Extra config for the network. Consider using
          {option}`services.znc.config` instead.
        '';

        example = ''
          Encoding = ^UTF-8
          FloodBurst = 4
          FloodRate = 1.00
          IRCConnectEnabled = true
          Ident = johntron
          JoinDelay = 0
          Nick = johntron
        '';

        type = types.lines;
      };

      hasBitlbeeControlChannel = mkOption {
        default = false;

        description = ''
          Whether to add the special Bitlbee operations channel.
        '';

        type = types.bool;
      };

      modules = mkOption {
        default = [ "simple_away" ];

        description = ''
          ZNC network modules to load.
        '';

        example = literalExpression ''[ "simple_away" "sasl" ]'';
        type = types.listOf types.str;
      };

      password = mkOption {
        default = "";

        description = ''
          IRC server password, such as for a Slack gateway.
        '';

        type = types.str;
      };

      port = mkOption {
        default = 6697;

        description = ''
          IRC server port.
        '';

        type = types.port;
      };

      server = mkOption {
        description = ''
          IRC server address.
        '';

        example = "irc.libera.chat";
        type = types.str;
      };

      useSSL = mkOption {
        default = true;

        description = ''
          Whether to use SSL to connect to the IRC server.
        '';

        type = types.bool;
      };
    };
  };

in

{

  imports = [
    (mkRemovedOptionModule [ "services" "znc" "zncConf" ] ''
      Instead of `services.znc.zncConf = "... foo ...";`, use
      `services.znc.configFile = pkgs.writeText "znc.conf" "... foo ...";`.
    '')
  ];

  options = {
    services.znc = {

      confOptions = {
        extraZncConf = mkOption {
          default = "";

          description = ''
            Extra config to {file}`znc.conf` file.
          '';

          type = types.lines;
        };

        modules = mkOption {
          default = [
            "webadmin"
            "adminlog"
          ];

          description = ''
            A list of modules to include in the {file}`znc.conf` file.
          '';

          example = [
            "partyline"
            "webadmin"
            "adminlog"
            "log"
          ];

          type = types.listOf types.str;
        };

        networks = mkOption {
          default = { };

          description = ''
            IRC networks to connect the user to.
          '';

          example = literalExpression ''
            {
              "libera" = {
                server = "irc.libera.chat";
                port = 6697;
                useSSL = true;
                modules = [ "simple_away" ];
              };
            };
          '';

          type = with types; attrsOf (submodule networkOpts);
        };

        nick = mkOption {
          default = "znc-user";

          description = ''
            The IRC nick.
          '';

          example = "john";
          type = types.str;
        };

        passBlock = mkOption {
          description = ''
            Generate with {command}`nix-shell -p znc --command "znc --makepass"`.
            This is the password used to log in to the ZNC web admin interface.
            You can also set this through
            {option}`services.znc.config.User.<username>.Pass.Method`
            and co.
          '';

          example = ''
            &lt;Pass password&gt;
               Method = sha256
               Hash = e2ce303c7ea75c571d80d8540a8699b46535be6a085be3414947d638e48d9e93
               Salt = l5Xryew4g*!oa(ECfX2o
            &lt;/Pass&gt;
          '';

          type = types.str;
        };

        port = mkOption {
          default = 5000;

          description = ''
            Specifies the port on which to listen.
          '';

          type = types.port;
        };

        uriPrefix = mkOption {
          default = null;

          description = ''
            An optional URI prefix for the ZNC web interface. Can be
            used to make ZNC available behind a reverse proxy.
          '';

          example = "/znc/";
          type = types.nullOr types.str;
        };

        useSSL = mkOption {
          default = true;

          description = ''
            Indicates whether the ZNC server should use SSL when listening on
            the specified port. A self-signed certificate will be generated.
          '';

          type = types.bool;
        };

        userModules = mkOption {
          default = [
            "chansaver"
            "controlpanel"
          ];

          description = ''
            A list of user modules to include in the {file}`znc.conf` file.
          '';

          example = [
            "chansaver"
            "controlpanel"
            "fish"
            "push"
          ];

          type = types.listOf types.str;
        };

        userName = mkOption {
          default = "znc";

          description = ''
            The user name used to log in to the ZNC web admin interface.
          '';

          example = "johntron";
          type = types.str;
        };
      };

      useLegacyConfig = mkOption {
        default = true;

        description = ''
          Whether to propagate the legacy options under
          {option}`services.znc.confOptions.*` to the znc config. If this
          is turned on, the znc config will contain a user with the default name
          "znc", global modules "webadmin" and "adminlog" will be enabled by
          default, and more, all controlled through the
          {option}`services.znc.confOptions.*` options.
          You can use {command}`nix-instantiate --eval --strict '<nixpkgs/nixos>' -A config.services.znc.config`
          to view the current value of the config.

          In any case, if you need more flexibility,
          {option}`services.znc.config` can be used to override/add to
          all of the legacy options.
        '';

        type = types.bool;
      };

    };
  };

  config = mkIf cfg.useLegacyConfig {

    services.znc.config =
      let
        c = cfg.confOptions;
        # defaults here should override defaults set in the non-legacy part
        mkDefault = mkOverride 900;
      in
      {
        Listener.l = {
          IPv4 = mkDefault true;
          IPv6 = mkDefault true;
          Port = mkDefault c.port;
          SSL = mkDefault c.useSSL;
          URIPrefix = c.uriPrefix;
        };

        LoadModule = mkDefault c.modules;

        User.${c.userName} = {
          Admin = mkDefault true;
          AltNick = mkDefault "${c.nick}_";
          Ident = mkDefault c.nick;
          LoadModule = mkDefault c.userModules;

          Network = mapAttrs (name: net: {
            Chan =
              optionalAttrs net.hasBitlbeeControlChannel { "&bitlbee" = mkDefault { }; }
              // listToAttrs (map (n: nameValuePair "#${n}" (mkDefault { })) net.channels);

            LoadModule = mkDefault net.modules;
            Server = mkDefault "${net.server} ${optionalString net.useSSL "+"}${toString net.port} ${net.password}";
            extraConfig = if net.extraConf == "" then mkDefault null else net.extraConf;
          }) c.networks;

          Nick = mkDefault c.nick;
          RealName = mkDefault c.nick;
          extraConfig = [ c.passBlock ];
        };

        extraConfig = optional (c.extraZncConf != "") c.extraZncConf;
      };
  };
}
