{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.namecoind;
  dataDir = "/var/lib/namecoind";
  useSSL = (cfg.rpc.certificate != null) && (cfg.rpc.key != null);
  useRPC = (cfg.rpc.user != null) && (cfg.rpc.password != null);

  listToConf = option: list: concatMapStrings (value: "${option}=${value}\n") list;

  configFile = pkgs.writeText "namecoin.conf" (
    ''
      server=1
      daemon=0
      txindex=1
      txprevcache=1
      walletpath=${cfg.wallet}
      gen=${if cfg.generate then "1" else "0"}
      ${listToConf "addnode" cfg.extraNodes}
      ${listToConf "connect" cfg.trustedNodes}
    ''
    + optionalString useRPC ''
      rpcbind=${cfg.rpc.address}
      rpcport=${toString cfg.rpc.port}
      rpcuser=${cfg.rpc.user}
      rpcpassword=${cfg.rpc.password}
      ${listToConf "rpcallowip" cfg.rpc.allowFrom}
    ''
    + optionalString useSSL ''
      rpcssl=1
      rpcsslcertificatechainfile=${cfg.rpc.certificate}
      rpcsslprivatekeyfile=${cfg.rpc.key}
      rpcsslciphers=TLSv1.2+HIGH:TLSv1+HIGH:!SSLv2:!aNULL:!eNULL:!3DES:@STRENGTH
    ''
  );

in

{

  ###### interface

  options = {

    services.namecoind = {

      enable = mkEnableOption "namecoind, Namecoin client";

      extraNodes = mkOption {
        default = [ ];

        description = ''
          List of additional peer IP addresses to connect to.
        '';

        type = types.listOf types.str;
      };

      generate = mkOption {
        default = false;

        description = ''
          Whether to generate (mine) Namecoins.
        '';

        type = types.bool;
      };

      rpc.address = mkOption {
        default = "0.0.0.0";

        description = ''
          IP address the RPC server will bind to.
        '';

        type = types.str;
      };

      rpc.allowFrom = mkOption {
        default = [ "127.0.0.1" ];

        description = ''
          List of IP address ranges allowed to use the RPC API.
          Wiledcards (*) can be user to specify a range.
        '';

        type = types.listOf types.str;
      };

      rpc.certificate = mkOption {
        default = null;

        description = ''
          Certificate file for securing RPC connections.
        '';

        example = "/var/lib/namecoind/server.cert";
        type = types.nullOr types.path;
      };

      rpc.key = mkOption {
        default = null;

        description = ''
          Key file for securing RPC connections.
        '';

        example = "/var/lib/namecoind/server.pem";
        type = types.nullOr types.path;
      };

      rpc.password = mkOption {
        default = null;

        description = ''
          Password for RPC connections.
        '';

        type = types.nullOr types.str;
      };

      rpc.port = mkOption {
        default = 8332;

        description = ''
          Port the RPC server will bind to.
        '';

        type = types.port;
      };

      rpc.user = mkOption {
        default = null;

        description = ''
          User name for RPC connections.
        '';

        type = types.nullOr types.str;
      };

      trustedNodes = mkOption {
        default = [ ];

        description = ''
          List of the only peer IP addresses to connect to. If specified
          no other connection will be made.
        '';

        type = types.listOf types.str;
      };

      wallet = mkOption {
        default = "${dataDir}/wallet.dat";

        description = ''
          Wallet file. The ownership of the file has to be
          namecoin:namecoin, and the permissions must be 0640.
        '';

        type = types.path;
      };

    };

  };

  ###### implementation

  config = mkIf cfg.enable {

    systemd.services.namecoind = {
      after = [ "network.target" ];
      description = "Namecoind daemon";

      preStart = optionalString (cfg.wallet != "${dataDir}/wallet.dat") ''
        # check wallet file permissions
        if [ "$(stat --printf '%u' ${cfg.wallet})" != "${toString config.ids.uids.namecoin}" \
           -o "$(stat --printf '%g' ${cfg.wallet})" != "${toString config.ids.gids.namecoin}" \
           -o "$(stat --printf '%a' ${cfg.wallet})" != "640" ]; then
           echo "ERROR: bad ownership or rights on ${cfg.wallet}" >&2
           exit 1
        fi
      '';

      serviceConfig = {
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        ExecStart = "${pkgs.namecoind}/bin/namecoind -conf=${configFile} -datadir=${dataDir} -printtoconsole";
        ExecStop = "${pkgs.coreutils}/bin/kill -KILL $MAINPID";
        Group = "namecoin";
        Nice = "10";
        PrivateTmp = true;
        Restart = "always";
        TimeoutStartSec = "2s";
        TimeoutStopSec = "60s";
        User = "namecoin";
      };

      startLimitBurst = 5;
      startLimitIntervalSec = 120;
      wantedBy = [ "multi-user.target" ];

    };

    users.groups.namecoin = {
      gid = config.ids.gids.namecoin;
    };

    users.users.namecoin = {
      createHome = true;
      description = "Namecoin daemon user";
      home = dataDir;
      uid = config.ids.uids.namecoin;
    };

  };

  meta.maintainers = with lib.maintainers; [ rnhmjoj ];

}
