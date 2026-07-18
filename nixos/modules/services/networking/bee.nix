{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.bee;
  format = pkgs.formats.yaml { };
  configFile = format.generate "bee.yaml" cfg.settings;
in
{
  ### interface
  options = {
    services.bee = {
      enable = lib.mkEnableOption "Ethereum Swarm Bee";

      package = lib.mkPackageOption pkgs "bee" {
        example = "bee-unstable";
      };

      daemonNiceLevel = lib.mkOption {
        default = 0;

        description = ''
          Daemon process priority for bee.
          0 is the default Unix process priority, 19 is the lowest.
        '';

        type = lib.types.int;
      };

      group = lib.mkOption {
        default = "bee";

        description = ''
          Group the bee binary should execute under.
        '';

        type = lib.types.str;
      };

      settings = lib.mkOption {
        description = ''
          Ethereum Swarm Bee configuration. Refer to
          <https://gateway.ethswarm.org/bzz/docs.swarm.eth/docs/installation/configuration/>
          for details on supported values.
        '';

        type = format.type;
      };

      user = lib.mkOption {
        default = "bee";

        description = ''
          User the bee binary should execute under.
        '';

        type = lib.types.str;
      };
    };
  };

  ### implementation
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = (lib.hasAttr "password" cfg.settings) != true;

        message = ''
          `services.bee.settings.password` is insecure. Use `services.bee.settings.password-file` or `systemd.services.bee.serviceConfig.EnvironmentFile` instead.
        '';
      }
      {
        assertion =
          (lib.hasAttr "swap-endpoint" cfg.settings) || (cfg.settings.swap-enable or true == false);

        message = ''
          In a swap-enabled network a working Ethereum blockchain node is required. You must specify one using `services.bee.settings.swap-endpoint`, or disable `services.bee.settings.swap-enable` = false.
        '';
      }
    ];

    services.bee.settings = {
      clef-signer-enable = lib.mkDefault true;
      data-dir = lib.mkDefault "/var/lib/bee";
      password-file = lib.mkDefault "/var/lib/bee/password";
      swap-endpoint = lib.mkDefault "https://rpc.slock.it/goerli";
    };

    systemd.packages = [ cfg.package ]; # include the upstream bee.service file

    systemd.services.bee = {
      preStart = with cfg.settings; ''
                if ! test -f ${password-file}; then
                  < /dev/urandom tr -dc _A-Z-a-z-0-9 2> /dev/null | head -c32 | install -m 600 /dev/stdin ${password-file}
                  echo "Initialized ${password-file} from /dev/urandom"
                fi
                if [ ! -f ${data-dir}/keys/libp2p.key ]; then
                  ${cfg.package}/bin/bee init --config=${configFile} >/dev/null
                  echo "
        Logs:   journalctl -f -u bee.service

        Bee has SWAP enabled by default and it needs ethereum endpoint to operate.
        It is recommended to use external signer with bee.
        Check documentation for more info:
        - SWAP https://docs.ethswarm.org/docs/installation/manual#swap-bandwidth-incentives

        After you finish configuration run 'sudo bee-get-addr'."
                fi
      '';

      serviceConfig = {
        ExecStart = [
          "" # this hides/overrides what's in the original entry
          "${cfg.package}/bin/bee --config=${configFile} start"
        ];

        Group = cfg.group;
        Nice = cfg.daemonNiceLevel;
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.settings.data-dir}' 0750 ${cfg.user} ${cfg.group}"
    ];

    users.groups = lib.optionalAttrs (cfg.group == "bee") {
      bee = { };
    };

    users.users = lib.optionalAttrs (cfg.user == "bee") {
      bee = {
        description = "Daemon user for Ethereum Swarm Bee";
        group = cfg.group;
        home = cfg.settings.data-dir;
        isSystemUser = true;
      };
    };
  };

  meta = {
    # doc = ./bee.xml;
    maintainers = [ ];
  };
}
