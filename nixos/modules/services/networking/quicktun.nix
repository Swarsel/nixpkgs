{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  inherit (lib) mkOption types mkIf;

  opt = options.services.quicktun;
  cfg = config.services.quicktun;
in
{
  options = {
    services.quicktun = mkOption {
      default = { };

      description = ''
        QuickTun tunnels.

        See <http://wiki.ucis.nl/QuickTun> for more information about available options.
      '';

      type = types.attrsOf (
        types.submodule (
          { name, ... }:
          let
            qtcfg = cfg.${name};
          in
          {
            options = {
              localAddress = mkOption {
                default = null;
                description = "IP address or hostname of the local end.";
                example = "0.0.0.0";
                type = with types; nullOr str;
              };

              localPort = mkOption {
                default = 2998;
                description = "Local UDP port.";
                type = types.port;
              };

              privateKey = mkOption {
                default = null;

                description = ''
                  Local secret key in hexadecimal form.

                  ::: {.warning}
                  This option is deprecated. Please use {var}`services.quicktun.<name>.privateKeyFile` instead.
                  :::

                  ::: {.note}
                  Not needed when {var}`services.quicktun.<name>.protocol` is set to `raw`.
                  :::
                '';

                type = with types; nullOr str;
              };

              privateKeyFile = mkOption {
                # This is a hack to deprecate `privateKey` without using `mkChangedModuleOption`
                default =
                  if qtcfg.privateKey == null then null else pkgs.writeText "quickttun-key-${name}" qtcfg.privateKey;

                defaultText = "null";

                description = ''
                  Path to file containing local secret key in binary or hexadecimal form.

                  ::: {.note}
                  Not needed when {var}`services.quicktun.<name>.protocol` is set to `raw`.
                  :::
                '';

                type = with types; nullOr path;
              };

              protocol = mkOption {
                default = "nacltai";
                description = "Which protocol to use.";

                type = types.enum [
                  "raw"
                  "nacl0"
                  "nacltai"
                  "salty"
                ];
              };

              publicKey = mkOption {
                default = null;

                description = ''
                  Remote public key in hexadecimal form.

                  ::: {.note}
                  Not needed when {var}`services.quicktun.<name>.protocol` is set to `raw`.
                  :::
                '';

                type = with types; nullOr str;
              };

              remoteAddress = mkOption {
                default = "0.0.0.0";

                description = ''
                  IP address or hostname of the remote end (use `0.0.0.0` for a floating/dynamic remote endpoint).
                '';

                example = "tunnel.example.com";
                type = types.str;
              };

              remoteFloat = mkOption {
                default = false;

                description = ''
                  Whether to allow the remote address and port to change when properly encrypted packets are received.
                '';

                example = true;
                type = with types; coercedTo bool (b: if b then 1 else 0) (ints.between 0 1);
              };

              remotePort = mkOption {
                default = qtcfg.localPort;
                defaultText = lib.literalExpression "config.services.quicktun.<name>.localPort";
                description = "Remote UDP port";
                type = types.port;
              };

              timeWindow = mkOption {
                default = 5;

                description = ''
                  Allowed time window for first received packet in seconds (positive number allows packets from history)
                '';

                type = types.ints.unsigned;
              };

              tunMode = mkOption {
                default = false;
                description = "Whether to operate in tun (IP) or tap (Ethernet) mode.";
                example = true;
                type = with types; coercedTo bool (b: if b then 1 else 0) (ints.between 0 1);
              };

              upScript = mkOption {
                default = null;

                description = ''
                  Run specified command or script after the tunnel device has been opened.
                '';

                type = with types; nullOr lines;
              };
            };
          }
        )
      );
    };
  };

  config = {
    systemd.services = lib.mkMerge (
      lib.mapAttrsToList (name: qtcfg: {
        "quicktun-${name}" = {
          after = [ "network.target" ];

          environment = {
            INTERFACE = name;
            LOCAL_ADDRESS = mkIf (qtcfg.localAddress != null) (qtcfg.localAddress);
            LOCAL_PORT = toString qtcfg.localPort;
            PRIVATE_KEY_FILE = mkIf (qtcfg.privateKeyFile != null) qtcfg.privateKeyFile;
            PUBLIC_KEY = mkIf (qtcfg.publicKey != null) qtcfg.publicKey;
            REMOTE_ADDRESS = qtcfg.remoteAddress;
            REMOTE_FLOAT = toString qtcfg.remoteFloat;
            REMOTE_PORT = toString qtcfg.remotePort;
            SUID = "nobody";
            TIME_WINDOW = toString qtcfg.timeWindow;
            TUN_MODE = toString qtcfg.tunMode;

            TUN_UP_SCRIPT = mkIf (qtcfg.upScript != null) (
              pkgs.writeScript "quicktun-${name}-up.sh" qtcfg.upScript
            );
          };

          serviceConfig = {
            ExecStart = "${pkgs.quicktun}/bin/quicktun.${qtcfg.protocol}";
            Type = "simple";
          };

          wantedBy = [ "multi-user.target" ];
        };
      }) cfg
    );

    warnings = lib.pipe cfg [
      (lib.mapAttrsToList (name: value: if value.privateKey != null then name else null))
      (builtins.filter (n: n != null))
      (map (n: "  - services.quicktun.${n}.privateKey"))
      (
        services:
        lib.optional (services != [ ]) ''
          `services.quicktun.<name>.privateKey` is deprecated.
          Please use `services.quicktun.<name>.privateKeyFile` instead.

          Offending options:
          ${lib.concatStringsSep "\n" services}
        ''
      )
    ];
  };
}
