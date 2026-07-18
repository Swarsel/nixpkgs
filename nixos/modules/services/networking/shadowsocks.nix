{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.shadowsocks;

  opts = {
    fast_open = cfg.fastOpen;
    method = cfg.encryptionMethod;
    mode = cfg.mode;
    server = cfg.localAddress;
    server_port = cfg.port;
    user = "nobody";
  }
  // optionalAttrs (cfg.plugin != null) {
    plugin = cfg.plugin;
    plugin_opts = cfg.pluginOpts;
  }
  // optionalAttrs (cfg.password != null) {
    password = cfg.password;
  }
  // cfg.extraConfig;

  configFile = pkgs.writeText "shadowsocks.json" (builtins.toJSON opts);

  executablesMap = {
    "${getName pkgs.shadowsocks-libev}" = {
      server = "ss-server";
    };

    "${getName pkgs.shadowsocks-rust}" = {
      server = "ssserver";
    };
  };
in
{

  ###### interface

  options = {

    services.shadowsocks = {

      enable = mkOption {
        default = false;

        description = ''
          Whether to run shadowsocks-libev shadowsocks server.
        '';

        type = types.bool;
      };

      package = mkPackageOption pkgs "Shadowsocks" {
        default = "shadowsocks-libev";
      };

      encryptionMethod = mkOption {
        default = "chacha20-ietf-poly1305";

        description = ''
          Encryption method. See <https://github.com/shadowsocks/shadowsocks-org/wiki/AEAD-Ciphers>.
        '';

        type = types.str;
      };

      extraConfig = mkOption {
        default = { };

        description = ''
          Additional configuration for shadowsocks that is not covered by the
          provided options. The provided attrset will be serialized to JSON and
          has to contain valid shadowsocks options. Unfortunately most
          additional options are undocumented but it's easy to find out what is
          available by looking into the source code of
          <https://github.com/shadowsocks/shadowsocks-libev/blob/master/src/jconf.c>
        '';

        example = {
          nameserver = "8.8.8.8";
        };

        type = types.attrs;
      };

      fastOpen = mkOption {
        default = true;

        description = ''
          use TCP fast-open
        '';

        type = types.bool;
      };

      localAddress = mkOption {
        # Keeped for compatibility
        default = [
          "[::0]"
          "0.0.0.0"
        ];

        description = ''
          Local addresses to which the server binds.
          Note: shadowsocks-rust accepts only string parameter.
        '';

        type =
          with types;
          oneOf [
            str
            (listOf str)
          ];
      };

      mode = mkOption {
        default = "tcp_and_udp";

        description = ''
          Relay protocols.
        '';

        type = types.enum [
          "tcp_only"
          "tcp_and_udp"
          "udp_only"
        ];
      };

      password = mkOption {
        default = null;

        description = ''
          Password for connecting clients.
        '';

        type = types.nullOr types.str;
      };

      passwordFile = mkOption {
        default = null;

        description = ''
          Password file with a password for connecting clients.
        '';

        type = types.nullOr types.path;
      };

      plugin = mkOption {
        default = null;

        description = ''
          SIP003 plugin for shadowsocks
        '';

        example = literalExpression ''"''${pkgs.shadowsocks-v2ray-plugin}/bin/v2ray-plugin"'';
        type = types.nullOr types.str;
      };

      pluginOpts = mkOption {
        default = "";

        description = ''
          Options to pass to the plugin if one was specified
        '';

        example = "server;host=example.com";
        type = types.str;
      };

      port = mkOption {
        default = 8388;

        description = ''
          Port which the server uses.
        '';

        type = types.port;
      };
    };

  };

  ###### implementation

  config = mkIf cfg.enable {
    assertions = [
      {
        # xor, make sure either password or passwordFile be set.
        # shadowsocks-libev not support plain/none encryption method
        # which indicated that password must set.
        assertion =
          let
            noPasswd = cfg.password == null;
            noPasswdFile = cfg.passwordFile == null;
          in
          (noPasswd && !noPasswdFile) || (!noPasswd && noPasswdFile);

        message = "Option `password` or `passwordFile` must be set and cannot be set simultaneously";
      }
      {
        # Ensure localAddress is a string if package is shadowsocks-rust
        assertion = !(getName cfg.package == "shadowsocks-rust" && !lib.strings.isString cfg.localAddress);
        message = "Option `localAddress` must be a string when using shadowsocks-rust.";
      }
    ];

    systemd.services.${getName cfg.package} = {
      after = [ "network.target" ];
      description = "${getName cfg.package} Daemon";

      path = [
        cfg.package
      ]
      ++ optional (cfg.plugin != null) cfg.plugin
      ++ optional (cfg.passwordFile != null) pkgs.jq;

      script = ''
        ${optionalString (cfg.passwordFile != null) ''
          cat ${configFile} | jq --arg password "$(cat "${cfg.passwordFile}")" '. + { password: $password }' > /tmp/shadowsocks.json
        ''}
        exec ${(executablesMap.${getName cfg.package}).server} -c ${
          if cfg.passwordFile != null then "/tmp/shadowsocks.json" else configFile
        }
      '';

      serviceConfig.PrivateTmp = true;
      wantedBy = [ "multi-user.target" ];
    };
  };
}
