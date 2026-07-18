{
  config,
  lib,
  pkgs,
  ...
}:
let

  eachBlockbook = config.services.blockbook-frontend;

  blockbookOpts =
    {
      config,
      lib,
      name,
      ...
    }:
    {

      options = {

        enable = lib.mkEnableOption "blockbook-frontend application";
        package = lib.mkPackageOption pkgs "blockbook" { };

        certFile = lib.mkOption {
          default = null;

          description = ''
            To enable SSL, specify path to the name of certificate files without extension.
            Expecting {file}`certFile.crt` and {file}`certFile.key`.
          '';

          example = "/etc/secrets/blockbook-frontend-${name}/certFile";
          type = lib.types.nullOr lib.types.path;
        };

        coinName = lib.mkOption {
          default = "Bitcoin";

          description = ''
            See <https://github.com/trezor/blockbook/blob/master/bchain/coins/blockchain.go#L61>
            for current of coins supported in master (Note: may differ from release).
          '';

          type = lib.types.str;
        };

        configFile = lib.mkOption {
          default = null;
          description = "Location of the blockbook configuration file.";
          example = "${config.dataDir}/config.json";
          type = with lib.types; nullOr path;
        };

        cssDir = lib.mkOption {
          default = "${config.package}/share/css/";
          defaultText = lib.literalExpression ''"''${package}/share/css/"'';

          description = ''
            Location of the dir with {file}`main.css` CSS file.
            By default, the one shipped with the package is used.
          '';

          example = lib.literalExpression ''"''${dataDir}/static/css/"'';
          type = lib.types.path;
        };

        dataDir = lib.mkOption {
          default = "/var/lib/blockbook-frontend-${name}";
          description = "Location of blockbook-frontend-${name} data directory.";
          type = lib.types.path;
        };

        debug = lib.mkOption {
          default = false;
          description = "Debug mode, return more verbose errors, reload templates on each request.";
          type = lib.types.bool;
        };

        extraCmdLineOptions = lib.mkOption {
          default = [ ];

          description = ''
            Extra command line options to pass to Blockbook.
            Run blockbook --help to list all available options.
          '';

          example = [
            "-workers=1"
            "-dbcache=0"
            "-logtosderr"
          ];

          type = lib.types.listOf lib.types.str;
        };

        extraConfig = lib.mkOption {
          default = { };

          description = ''
            Additional configurations to be appended to {file}`coin.conf`.
            Overrides any already defined configuration options.
            See <https://github.com/trezor/blockbook/tree/master/configs/coins>
            for current configuration options supported in master (Note: may differ from release).
          '';

          example = lib.literalExpression ''
            {
                     "alternative_estimate_fee" = "whatthefee-disabled";
                     "alternative_estimate_fee_params" = "{\"url\": \"https://whatthefee.io/data.json\", \"periodSeconds\": 60}";
                     "fiat_rates" = "coingecko";
                     "fiat_rates_params" = "{\"url\": \"https://api.coingecko.com/api/v3\", \"coin\": \"bitcoin\", \"periodSeconds\": 60}";
                     "coin_shortcut" = "BTC";
                     "coin_label" = "Bitcoin";
                     "parse" = true;
                     "subversion" = "";
                     "address_format" = "";
                     "xpub_magic" = 76067358;
                     "xpub_magic_segwit_p2sh" = 77429938;
                     "xpub_magic_segwit_native" = 78792518;
                     "mempool_workers" = 8;
                     "mempool_sub_workers" = 2;
                     "block_addresses_to_keep" = 300;
                   }'';

          type = lib.types.attrs;
        };

        group = lib.mkOption {
          default = "${config.user}";
          description = "The group as which to run blockbook-frontend-${name}.";
          type = lib.types.str;
        };

        internal = lib.mkOption {
          default = ":9030";
          description = "Internal http server binding `[address]:port`.";
          type = lib.types.nullOr lib.types.str;
        };

        messageQueueBinding = lib.mkOption {
          default = "tcp://127.0.0.1:38330";
          description = "Message Queue Binding `address:port`.";
          type = lib.types.str;
        };

        public = lib.mkOption {
          default = ":9130";
          description = "Public http server binding `[address]:port`.";
          type = lib.types.nullOr lib.types.str;
        };

        rpc = {
          password = lib.mkOption {
            default = "rpc";

            description = ''
              RPC password for JSON-RPC connections.
              Warning: this is stored in cleartext in the Nix store!!!
              Use `configFile` or `passwordFile` if needed.
            '';

            type = lib.types.str;
          };

          passwordFile = lib.mkOption {
            default = null;

            description = ''
              File containing password of the RPC user.
              Note: This options is ignored when `configFile` is used.
            '';

            type = lib.types.nullOr lib.types.path;
          };

          port = lib.mkOption {
            default = 8030;
            description = "Port for JSON-RPC connections.";
            type = lib.types.port;
          };

          url = lib.mkOption {
            default = "http://127.0.0.1";
            description = "URL for JSON-RPC connections.";
            type = lib.types.str;
          };

          user = lib.mkOption {
            default = "rpc";
            description = "Username for JSON-RPC connections.";
            type = lib.types.str;
          };
        };

        sync = lib.mkOption {
          default = true;
          description = "Synchronizes until tip, if together with zeromq, keeps index synchronized.";
          type = lib.types.bool;
        };

        templateDir = lib.mkOption {
          default = "${config.package}/share/templates/";
          defaultText = lib.literalExpression ''"''${package}/share/templates/"'';
          description = "Location of the HTML templates. By default, ones shipped with the package are used.";
          example = lib.literalExpression ''"''${dataDir}/templates/static/"'';
          type = lib.types.path;
        };

        user = lib.mkOption {
          default = "blockbook-frontend-${name}";
          description = "The user as which to run blockbook-frontend-${name}.";
          type = lib.types.str;
        };
      };
    };
in
{
  # interface

  options = {
    services.blockbook-frontend = lib.mkOption {
      default = { };
      description = "Specification of one or more blockbook-frontend instances.";
      type = lib.types.attrsOf (lib.types.submodule blockbookOpts);
    };
  };

  # implementation

  config = lib.mkIf (eachBlockbook != { }) {

    systemd.services = lib.mapAttrs' (
      blockbookName: cfg:
      (lib.nameValuePair "blockbook-frontend-${blockbookName}" (
        let
          configFile =
            if cfg.configFile != null then
              cfg.configFile
            else
              pkgs.writeText "config.conf" (
                builtins.toJSON (
                  {
                    coin_name = "${cfg.coinName}";
                    message_queue_binding = "${cfg.messageQueueBinding}";
                    rpc_pass = "${cfg.rpc.password}";
                    rpc_url = "${cfg.rpc.url}:${toString cfg.rpc.port}";
                    rpc_user = "${cfg.rpc.user}";
                  }
                  // cfg.extraConfig
                )
              );
        in
        {
          after = [ "network.target" ];
          description = "blockbook-frontend-${blockbookName} daemon";

          preStart = ''
            ln -sf ${cfg.templateDir} ${cfg.dataDir}/static/
            ln -sf ${cfg.cssDir} ${cfg.dataDir}/static/
            ${lib.optionalString (cfg.rpc.passwordFile != null && cfg.configFile == null) ''
              CONFIGTMP=$(mktemp)
              ${pkgs.jq}/bin/jq ".rpc_pass = \"$(cat ${cfg.rpc.passwordFile})\"" ${configFile} > $CONFIGTMP
              mv $CONFIGTMP ${cfg.dataDir}/${blockbookName}-config.json
            ''}
          '';

          serviceConfig = {
            ExecStart = ''
              ${cfg.package}/bin/blockbook \
              ${
                if (cfg.rpc.passwordFile != null && cfg.configFile == null) then
                  "-blockchaincfg=${cfg.dataDir}/${blockbookName}-config.json"
                else
                  "-blockchaincfg=${configFile}"
              } \
              -datadir=${cfg.dataDir} \
              ${lib.optionalString (cfg.sync != false) "-sync"} \
              ${lib.optionalString (cfg.certFile != null) "-certfile=${toString cfg.certFile}"} \
              ${lib.optionalString (cfg.debug != false) "-debug"} \
              ${lib.optionalString (cfg.internal != null) "-internal=${toString cfg.internal}"} \
              ${lib.optionalString (cfg.public != null) "-public=${toString cfg.public}"} \
              ${toString cfg.extraCmdLineOptions}
            '';

            Group = cfg.group;
            LimitNOFILE = 65536;
            Restart = "on-failure";
            User = cfg.user;
            WorkingDirectory = cfg.dataDir;
          };

          wantedBy = [ "multi-user.target" ];
        }
      ))
    ) eachBlockbook;

    systemd.tmpfiles.rules = lib.flatten (
      lib.mapAttrsToList (blockbookName: cfg: [
        "d ${cfg.dataDir} 0750 ${cfg.user} ${cfg.group} - -"
        "d ${cfg.dataDir}/static 0750 ${cfg.user} ${cfg.group} - -"
      ]) eachBlockbook
    );

    users.groups = lib.mapAttrs' (
      instanceName: cfg: (lib.nameValuePair "${cfg.group}" { })
    ) eachBlockbook;

    users.users = lib.mapAttrs' (
      blockbookName: cfg:
      (lib.nameValuePair "blockbook-frontend-${blockbookName}" {
        group = cfg.group;
        home = cfg.dataDir;
        isSystemUser = true;
        name = cfg.user;
      })
    ) eachBlockbook;
  };

  meta.maintainers = with lib.maintainers; [ _1000101 ];

}
