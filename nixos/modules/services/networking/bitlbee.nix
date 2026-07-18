{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.bitlbee;
  bitlbeeUid = config.ids.uids.bitlbee;

  bitlbeePkg = pkgs.bitlbee.override {
    enableLibPurple = cfg.libpurple_plugins != [ ];
    enablePam = cfg.authBackend == "pam";
  };

  bitlbeeConfig = pkgs.writeText "bitlbee.conf" ''
    [settings]
    RunMode = Daemon
    ConfigDir = ${cfg.configDir}
    DaemonInterface = ${cfg.interface}
    DaemonPort = ${toString cfg.portNumber}
    AuthMode = ${cfg.authMode}
    AuthBackend = ${cfg.authBackend}
    Plugindir = ${pkgs.bitlbee-plugins cfg.plugins}/lib/bitlbee
    ${lib.optionalString (cfg.hostName != "") "HostName = ${cfg.hostName}"}
    ${lib.optionalString (cfg.protocols != "") "Protocols = ${cfg.protocols}"}
    ${cfg.extraSettings}

    [defaults]
    ${cfg.extraDefaults}
  '';

  purple_plugin_path = lib.concatMapStringsSep ":" (
    plugin: "${plugin}/lib/pidgin/:${plugin}/lib/purple-2/"
  ) cfg.libpurple_plugins;

in

{

  ###### interface

  options = {

    services.bitlbee = {

      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to run the BitlBee IRC to other chat network gateway.
          Running it allows you to access the MSN, Jabber, Yahoo! and ICQ chat
          networks via an IRC client.
        '';

        type = lib.types.bool;
      };

      authBackend = lib.mkOption {
        default = "storage";

        description = ''
          How users are authenticated
            storage -- save passwords internally
            pam -- Linux PAM authentication
        '';

        type = lib.types.enum [
          "storage"
          "pam"
        ];
      };

      authMode = lib.mkOption {
        default = "Open";

        description = ''
          The following authentication modes are available:
            Open -- Accept connections from anyone, use NickServ for user authentication.
            Closed -- Require authorization (using the PASS command during login) before allowing the user to connect at all.
            Registered -- Only allow registered users to use this server; this disables the register- and the account command until the user identifies himself.
        '';

        type = lib.types.enum [
          "Open"
          "Closed"
          "Registered"
        ];
      };

      configDir = lib.mkOption {
        default = "/var/lib/bitlbee";

        description = ''
          Specify an alternative directory to store all the per-user configuration
          files.
        '';

        type = lib.types.path;
      };

      extraDefaults = lib.mkOption {
        default = "";

        description = ''
          Will be inserted in the Default section of the config file.
        '';

        type = lib.types.lines;
      };

      extraSettings = lib.mkOption {
        default = "";

        description = ''
          Will be inserted in the Settings section of the config file.
        '';

        type = lib.types.lines;
      };

      hostName = lib.mkOption {
        default = "";

        description = ''
          Normally, BitlBee gets a hostname using getsockname(). If you have a nicer
          alias for your BitlBee daemon, you can set it here and BitlBee will identify
          itself with that name instead.
        '';

        type = lib.types.str;
      };

      interface = lib.mkOption {
        default = "127.0.0.1";

        description = ''
          The interface the BitlBee daemon will be listening to.  If `127.0.0.1`,
          only clients on the local host can connect to it; if `0.0.0.0`, clients
          can access it from any network interface.
        '';

        type = lib.types.str;
      };

      libpurple_plugins = lib.mkOption {
        default = [ ];

        description = ''
          The list of libpurple plugins to install.
        '';

        example = lib.literalExpression "[ pkgs.purple-discord ]";
        type = lib.types.listOf lib.types.package;
      };

      plugins = lib.mkOption {
        default = [ ];

        description = ''
          The list of bitlbee plugins to install.
        '';

        example = lib.literalExpression "[ pkgs.bitlbee-facebook ]";
        type = lib.types.listOf lib.types.package;
      };

      portNumber = lib.mkOption {
        default = 6667;

        description = ''
          Number of the port BitlBee will be listening to.
        '';

        type = lib.types.port;
      };

      protocols = lib.mkOption {
        default = "";

        description = ''
          This option allows to remove the support of protocol, even if compiled
          in. If nothing is given, there are no restrictions.
        '';

        type = lib.types.str;
      };

    };

  };

  ###### implementation

  config = lib.mkMerge [
    (lib.mkIf config.services.bitlbee.enable {
      environment.systemPackages = [ bitlbeePkg ];

      systemd.services.bitlbee = {
        after = [ "network.target" ];
        description = "BitlBee IRC to other chat networks gateway";
        environment.PURPLE_PLUGIN_PATH = purple_plugin_path;

        serviceConfig = {
          DynamicUser = true;
          ExecStart = "${bitlbeePkg}/sbin/bitlbee -F -n -c ${bitlbeeConfig}";
          ReadWritePaths = [ cfg.configDir ];
          StateDirectory = "bitlbee";
        };

        wantedBy = [ "multi-user.target" ];
      };

    })
    (lib.mkIf (config.services.bitlbee.authBackend == "pam") {
      security.pam.services.bitlbee = { };
    })
  ];

}
