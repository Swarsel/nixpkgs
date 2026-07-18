{
  config,
  lib,
  pkgs,
  ...
}:

let

  cfg = config.services.ttyd;

  inherit (lib)
    optionals
    types
    mkOption
    ;

  # Command line arguments for the ttyd daemon
  args = [
    "--port"
    (toString cfg.port)
  ]
  ++ optionals (cfg.socket != null) [
    "--interface"
    cfg.socket
  ]
  ++ optionals (cfg.interface != null) [
    "--interface"
    cfg.interface
  ]
  ++ [
    "--signal"
    (toString cfg.signal)
  ]
  ++ (lib.concatLists (
    lib.mapAttrsToList (_k: _v: [
      "--client-option"
      "${_k}=${_v}"
    ]) cfg.clientOptions
  ))
  ++ [
    "--terminal-type"
    cfg.terminalType
  ]
  ++ optionals cfg.checkOrigin [ "--check-origin" ]
  ++ optionals cfg.writeable [ "--writable" ] # the typo is correct
  ++ [
    "--max-clients"
    (toString cfg.maxClients)
  ]
  ++ optionals (cfg.indexFile != null) [
    "--index"
    cfg.indexFile
  ]
  ++ optionals cfg.enableIPv6 [ "--ipv6" ]
  ++ optionals cfg.enableSSL [
    "--ssl"
    "--ssl-cert"
    cfg.certFile
    "--ssl-key"
    cfg.keyFile
  ]
  ++ optionals (cfg.enableSSL && cfg.caFile != null) [
    "--ssl-ca"
    cfg.caFile
  ]
  ++ [
    "--debug"
    (toString cfg.logLevel)
  ];

in

{

  ###### interface

  options = {
    services.ttyd = {
      enable = lib.mkEnableOption "ttyd daemon";

      caFile = mkOption {
        default = null;
        description = "SSL CA file path for client certificate verification.";
        type = types.nullOr types.path;
      };

      certFile = mkOption {
        default = null;
        description = "SSL certificate file path.";
        type = types.nullOr types.path;
      };

      checkOrigin = mkOption {
        default = false;
        description = "Whether to allow a websocket connection from a different origin.";
        type = types.bool;
      };

      clientOptions = mkOption {
        default = { };

        description = ''
          Attribute set of client options for xtermjs.
          <https://xtermjs.org/docs/api/terminal/interfaces/iterminaloptions/>
        '';

        example = lib.literalExpression ''
          {
            fontSize = "16";
            fontFamily = "Fira Code";
          }
        '';

        type = types.attrsOf types.str;
      };

      enableIPv6 = mkOption {
        default = false;
        description = "Whether or not to enable IPv6 support.";
        type = types.bool;
      };

      enableSSL = mkOption {
        default = false;
        description = "Whether or not to enable SSL (https) support.";
        type = types.bool;
      };

      entrypoint = mkOption {
        apply = lib.escapeShellArgs;
        default = [ "${pkgs.shadow}/bin/login" ];

        defaultText = lib.literalExpression ''
          [ "''${pkgs.shadow}/bin/login" ]
        '';

        description = "Which command ttyd runs.";

        example = lib.literalExpression ''
          [ (lib.getExe pkgs.htop) ]
        '';

        type = types.listOf types.str;
      };

      indexFile = mkOption {
        default = null;
        description = "Custom index.html path";
        type = types.nullOr types.path;
      };

      interface = mkOption {
        default = null;
        description = "Network interface to bind.";
        example = "eth0";
        type = types.nullOr types.str;
      };

      keyFile = mkOption {
        apply = value: if value == null then null else toString value;
        default = null;

        description = ''
          SSL key file path.
          For insecurely putting the keyFile in the globally readable store use
          `pkgs.writeText "ttydKeyFile" "SSLKEY"`.
        '';

        type = types.nullOr types.path;
      };

      logLevel = mkOption {
        default = 7;
        description = "Set log level.";
        type = types.int;
      };

      maxClients = mkOption {
        default = 0;
        description = "Maximum clients to support (0, no limit)";
        type = types.int;
      };

      passwordFile = mkOption {
        apply = value: if value == null then null else toString value;
        default = null;

        description = ''
          File containing the password to use for basic http authentication.
          For insecurely putting the password in the globally readable store use
          `pkgs.writeText "ttydpw" "MyPassword"`.
        '';

        type = types.nullOr types.path;
      };

      port = mkOption {
        default = 7681;
        description = "Port to listen on (use 0 for random port)";
        type = types.port;
      };

      signal = mkOption {
        default = 1;
        description = "Signal to send to the command on session close.";
        type = types.ints.u8;
      };

      socket = mkOption {
        default = null;
        description = "UNIX domain socket path to bind.";
        example = "/var/run/ttyd.sock";
        type = types.nullOr types.path;
      };

      terminalType = mkOption {
        default = "xterm-256color";
        description = "Terminal type to report.";
        type = types.str;
      };

      user = mkOption {
        # `login` needs to be run as root
        default = "root";
        description = "Which unix user ttyd should run as.";
        type = types.str;
      };

      username = mkOption {
        default = null;
        description = "Username for basic http authentication.";
        type = types.nullOr types.str;
      };

      writeable = mkOption {
        default = null; # null causes an eval error, forcing the user to consider attack surface
        description = "Allow clients to write to the TTY.";
        example = true;
        type = types.nullOr types.bool;
      };
    };
  };

  ###### implementation

  config = lib.mkIf cfg.enable {

    assertions = [
      {
        assertion = cfg.enableSSL -> cfg.certFile != null && cfg.keyFile != null;
        message = "SSL is enabled for ttyd, but no certFile or keyFile has been specified.";
      }
      {
        assertion = cfg.writeable != null;
        message = "services.ttyd.writeable must be set";
      }
      {
        assertion = !(cfg.interface != null && cfg.socket != null);
        message = "Cannot set both interface and socket for ttyd.";
      }
      {
        assertion = (cfg.username != null) == (cfg.passwordFile != null);
        message = "Need to set both username and passwordFile for ttyd";
      }
    ];

    systemd.services.ttyd = {
      description = "ttyd Web Server Daemon";

      script =
        if cfg.passwordFile != null then
          ''
            PASSWORD=$(cat "$CREDENTIALS_DIRECTORY/TTYD_PASSWORD_FILE")
            ${pkgs.ttyd}/bin/ttyd ${lib.escapeShellArgs args} \
              --credential ${lib.escapeShellArg cfg.username}:"$PASSWORD" \
              ${cfg.entrypoint}
          ''
        else
          ''
            ${pkgs.ttyd}/bin/ttyd ${lib.escapeShellArgs args} \
              ${cfg.entrypoint}
          '';

      serviceConfig = {
        LoadCredential = lib.optionalString (
          cfg.passwordFile != null
        ) "TTYD_PASSWORD_FILE:${cfg.passwordFile}";

        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
