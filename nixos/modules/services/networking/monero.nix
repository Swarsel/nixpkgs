{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.monero;

  listToConf = option: list: lib.concatMapStrings (value: "${option}=${value}\n") list;

  login = (cfg.rpc.user != null && cfg.rpc.password != null);

  configFile =
    with cfg;
    pkgs.writeText "monero.conf" ''
      log-file=/dev/stdout
      data-dir=${dataDir}

      ${lib.optionalString mining.enable ''
        start-mining=${mining.address}
        mining-threads=${toString mining.threads}
      ''}

      rpc-bind-ip=${rpc.address}
      rpc-bind-port=${toString rpc.port}
      ${lib.optionalString login ''
        rpc-login=${rpc.user}:${rpc.password}
      ''}
      ${lib.optionalString rpc.restricted ''
        restricted-rpc=1
      ''}

      ${lib.optionalString (banlist != null) ''
        ban-list=${banlist}
      ''}

      limit-rate-up=${toString limits.upload}
      limit-rate-down=${toString limits.download}
      max-concurrency=${toString limits.threads}
      block-sync-size=${toString limits.syncSize}

      ${listToConf "add-peer" extraNodes}
      ${listToConf "add-priority-node" priorityNodes}
      ${listToConf "add-exclusive-node" exclusiveNodes}

      ${lib.optionalString prune ''
        prune-blockchain=1
        sync-pruned-blocks=1
      ''}

      ${extraConfig}
    '';

in

{

  ###### interface

  options = {

    services.monero = {

      enable = lib.mkEnableOption "Monero node daemon";

      banlist = lib.mkOption {
        default = null;

        description = ''
          Path to a text file containing IPs to block.
          Useful to prevent DDoS/deanonymization attacks.

          <https://github.com/monero-project/meta/issues/1124>
        '';

        example = lib.literalExpression ''
          builtins.fetchurl {
            url = "https://raw.githubusercontent.com/rblaine95/monero-banlist/c6eb9413ddc777e7072d822f49923df0b2a94d88/block.txt";
            hash = "";
          };
        '';

        type = lib.types.nullOr lib.types.path;
      };

      dataDir = lib.mkOption {
        default = "/var/lib/monero";

        description = ''
          The directory where Monero stores its data files.
        '';

        type = lib.types.str;
      };

      environmentFile = lib.mkOption {
        default = null;

        description = ''
          Path to an EnvironmentFile for the monero service as defined in {manpage}`systemd.exec(5)`.

          Secrets may be passed to the service by specifying placeholder variables in the Nix config
          and setting values in the environment file.

          Example:

          ```
          # In environment file:
          MINING_ADDRESS=888tNkZrPN6JsEgekjMnABU4TBzc2Dt29EPAvkRxbANsAnjyPbb3iQ1YBRk1UXcdRsiKc9dhwMVgN5S9cQUiyoogDavup3H
          ```

          ```
          # Service config
          services.monero.mining.address = "$MINING_ADDRESS";
          ```
        '';

        example = "/var/lib/monero/monerod.env";
        type = lib.types.nullOr lib.types.path;
      };

      exclusiveNodes = lib.mkOption {
        default = [ ];

        description = ''
          List of peer IP addresses to connect to *only*.
          If given the other peer options will be ignored.
        '';

        type = lib.types.listOf lib.types.str;
      };

      extraConfig = lib.mkOption {
        default = "";

        description = ''
          Extra lines to be added verbatim to monerod configuration.
        '';

        type = lib.types.lines;
      };

      extraNodes = lib.mkOption {
        default = [ ];

        description = ''
          List of additional peer IP addresses to add to the local list.
        '';

        type = lib.types.listOf lib.types.str;
      };

      limits.download = lib.mkOption {
        default = -1;

        description = ''
          Limit of the download rate in kB/s.
          Set to `-1` to leave unlimited.
        '';

        type = lib.types.addCheck lib.types.int (x: x >= -1);
      };

      limits.syncSize = lib.mkOption {
        default = 0;

        description = ''
          Maximum number of blocks to sync at once.
          Set to `0` for adaptive.
        '';

        type = lib.types.ints.unsigned;
      };

      limits.threads = lib.mkOption {
        default = 0;

        description = ''
          Maximum number of threads used for a parallel job.
          Set to `0` to leave unlimited.
        '';

        type = lib.types.ints.unsigned;
      };

      limits.upload = lib.mkOption {
        default = -1;

        description = ''
          Limit of the upload rate in kB/s.
          Set to `-1` to leave unlimited.
        '';

        type = lib.types.addCheck lib.types.int (x: x >= -1);
      };

      mining.address = lib.mkOption {
        default = "";

        description = ''
          Monero address where to send mining rewards.
        '';

        type = lib.types.str;
      };

      mining.enable = lib.mkOption {
        default = false;

        description = ''
          Whether to mine monero.
        '';

        type = lib.types.bool;
      };

      mining.threads = lib.mkOption {
        default = 0;

        description = ''
          Number of threads used for mining.
          Set to `0` to use all available.
        '';

        type = lib.types.ints.unsigned;
      };

      priorityNodes = lib.mkOption {
        default = [ ];

        description = ''
          List of peer IP addresses to connect to and
          attempt to keep the connection open.
        '';

        type = lib.types.listOf lib.types.str;
      };

      prune = lib.mkOption {
        default = false;

        description = ''
          Whether to prune the blockchain.
          <https://www.getmonero.org/resources/moneropedia/pruning.html>
        '';

        type = lib.types.bool;
      };

      rpc.address = lib.mkOption {
        default = "127.0.0.1";

        description = ''
          IP address the RPC server will bind to.
        '';

        type = lib.types.str;
      };

      rpc.password = lib.mkOption {
        default = null;

        description = ''
          Password for RPC connections.
        '';

        type = lib.types.nullOr lib.types.str;
      };

      rpc.port = lib.mkOption {
        default = 18081;

        description = ''
          Port the RPC server will bind to.
        '';

        type = lib.types.port;
      };

      rpc.restricted = lib.mkOption {
        default = false;

        description = ''
          Whether to restrict RPC to view only commands.
        '';

        type = lib.types.bool;
      };

      rpc.user = lib.mkOption {
        default = null;

        description = ''
          User name for RPC connections.
        '';

        type = lib.types.nullOr lib.types.str;
      };

    };

  };

  ###### implementation

  config = lib.mkIf cfg.enable {

    assertions = lib.singleton {
      assertion = cfg.mining.enable -> cfg.mining.address != "";

      message = ''
        You need a Monero address to receive mining rewards:
        specify one using option monero.mining.address.
      '';
    };

    systemd.services.monero = {
      after = [ "network.target" ];
      description = "monero daemon";

      preStart = ''
        umask 077
        ${pkgs.envsubst}/bin/envsubst \
          -i ${configFile} \
          -o ${cfg.dataDir}/monerod.conf
      '';

      serviceConfig = {
        EnvironmentFile = lib.mkIf (cfg.environmentFile != null) [ cfg.environmentFile ];
        ExecStart = "${lib.getExe' pkgs.monero-cli "monerod"} --config-file=${cfg.dataDir}/monerod.conf --non-interactive";
        Group = "monero";
        Restart = "always";

        SuccessExitStatus = [
          0
          1
        ];

        User = "monero";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.monero = { };

    users.users.monero = {
      createHome = true;
      description = "Monero daemon user";
      group = "monero";
      home = cfg.dataDir;
      isSystemUser = true;
    };

  };

  meta.maintainers = with lib.maintainers; [ rnhmjoj ];

}
