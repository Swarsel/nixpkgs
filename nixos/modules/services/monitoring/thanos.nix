{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    collect
    concatLists
    concatStringsSep
    flip
    getAttrFromPath
    hasPrefix
    isList
    length
    literalExpression
    literalMD
    mapAttrsRecursiveCond
    mapAttrsToList
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    mkPackageOption
    optional
    optionalAttrs
    optionalString
    types
    ;

  cfg = config.services.thanos;

  nullOpt =
    type: description:
    mkOption {
      default = null;
      description = description;
      type = if type.check null then type else types.nullOr type;
    };

  optionToArgs = opt: v: optional (v != null) ''--${opt}="${toString v}"'';
  flagToArgs = opt: v: optional v "--${opt}";
  listToArgs = opt: vs: map (v: ''--${opt}="${v}"'') vs;
  attrsToArgs = opt: kvs: mapAttrsToList (k: v: ''--${opt}=${k}=\"${v}\"'') kvs;

  mkParamDef =
    type: default: description:
    mkParam type (
      description
      + ''

        Defaults to `${toString default}` in Thanos
        when set to `null`.
      ''
    );

  mkParam = type: description: {
    option = nullOpt type description;
    toArgs = optionToArgs;
  };

  mkFlagParam = description: {
    option = mkOption {
      default = false;
      description = description;
      type = types.bool;
    };

    toArgs = flagToArgs;
  };

  mkListParam = opt: description: {
    option = mkOption {
      default = [ ];
      description = description;
      type = types.listOf types.str;
    };

    toArgs = _opt: listToArgs opt;
  };

  mkAttrsParam = opt: description: {
    option = mkOption {
      default = { };
      description = description;
      type = types.attrsOf types.str;
    };

    toArgs = _opt: attrsToArgs opt;
  };

  mkStateDirParam = opt: default: description: {
    option = mkOption {
      inherit default;
      description = description;
      type = types.str;
    };

    toArgs = _opt: stateDir: optionToArgs opt "/var/lib/${stateDir}";
  };

  format = pkgs.formats.yaml { };

  thanos =
    cmd:
    "${cfg.package}/bin/thanos ${cmd}"
    + (
      let
        args = cfg.${cmd}.arguments;
      in
      optionalString (length args != 0) (" \\\n  " + concatStringsSep " \\\n  " args)
    );

  argumentsOf =
    cmd:
    concatLists (
      collect isList (
        flip mapParamsRecursive params.${cmd} (
          path: param:
          let
            opt = concatStringsSep "." path;
            v = getAttrFromPath path cfg.${cmd};
          in
          param.toArgs opt v
        )
      )
    );

  mkArgumentsOption =
    cmd:
    mkOption {
      default = argumentsOf cmd;

      defaultText = literalMD ''
        calculated from `config.services.thanos.${cmd}`
      '';

      description = ''
        Arguments to the `thanos ${cmd}` command.

        Defaults to a list of arguments formed by converting the structured
        options of {option}`services.thanos.${cmd}` to a list of arguments.

        Overriding this option will cause none of the structured options to have
        any effect. So only set this if you know what you're doing!
      '';

      type = types.listOf types.str;
    };

  mapParamsRecursive =
    let
      noParam = attr: !(attr ? toArgs && attr ? option);
    in
    mapAttrsRecursiveCond noParam;

  paramsToOptions = mapParamsRecursive (_path: param: param.option);

  params = {

    common =
      cfg:
      params.log
      // params.tracing cfg
      // {

        grpc-address = mkParamDef types.str "0.0.0.0:10901" ''
          Listen `ip:port` address for gRPC endpoints (StoreAPI).

          Make sure this address is routable from other components.
        '';

        grpc-server-tls-cert = mkParam types.str ''
          TLS Certificate for gRPC server, leave blank to disable TLS
        '';

        grpc-server-tls-client-ca = mkParam types.str ''
          TLS CA to verify clients against.

          If no client CA is specified, there is no client verification on server side.
          (tls.NoClientCert)
        '';

        grpc-server-tls-key = mkParam types.str ''
          TLS Key for the gRPC server, leave blank to disable TLS
        '';

        http-address = mkParamDef types.str "0.0.0.0:10902" ''
          Listen `host:port` for HTTP endpoints.
        '';
      };

    compact =
      params.log
      // params.tracing cfg.compact
      // params.objstore cfg.compact
      // {

        compact.concurrency = mkParamDef types.int 1 ''
          Number of goroutines to use when compacting groups.
        '';

        consistency-delay = mkParamDef types.str "30m" ''
          Minimum age of fresh (non-compacted) blocks before they are being
          processed. Malformed blocks older than the maximum of consistency-delay
          and 30m0s will be removed.
        '';

        downsampling.disable = mkFlagParam ''
          Disables downsampling.

          This is not recommended as querying long time ranges without
          non-downsampled data is not efficient and useful e.g it is not possible
          to render all samples for a human eye anyway
        '';

        http-address = mkParamDef types.str "0.0.0.0:10902" ''
          Listen `host:port` for HTTP endpoints.
        '';

        retention.resolution-1h = mkParamDef types.str "0d" ''
          How long to retain samples of resolution 2 (1 hour) in bucket.

          `0d` - disables this retention
        '';

        retention.resolution-5m = mkParamDef types.str "0d" ''
          How long to retain samples of resolution 1 (5 minutes) in bucket.

          `0d` - disables this retention
        '';

        retention.resolution-raw = mkParamDef types.str "0d" ''
          How long to retain raw samples in bucket.

          `0d` - disables this retention
        '';

        startAt = {
          option = nullOpt types.str ''
            When this option is set to a `systemd.time`
            specification the Thanos compactor will run at the specified period.

            When this option is `null` the Thanos compactor service
            will run continuously. So it will not exit after all compactions have
            been processed but wait for new work.
          '';

          toArgs = _opt: startAt: flagToArgs "wait" (startAt == null);
        };

        stateDir = mkStateDirParam "data-dir" "thanos-compact" ''
          Data directory relative to `/var/lib`
          in which to cache blocks and process compactions.
        '';
      };

    downsample =
      params.log
      // params.tracing cfg.downsample
      // params.objstore cfg.downsample
      // {

        stateDir = mkStateDirParam "data-dir" "thanos-downsample" ''
          Data directory relative to `/var/lib`
          in which to cache blocks and process downsamplings.
        '';

      };

    log = {

      log.format = mkParam types.str ''
        Log format to use.
      '';

      log.level =
        mkParamDef
          (types.enum [
            "debug"
            "info"
            "warn"
            "error"
            "fatal"
          ])
          "info"
          ''
            Log filtering level.
          '';
    };

    objstore = cfg: {

      objstore.config = {
        option = nullOpt format.type ''
          Object store configuration.

          When not `null` the attribute set gets converted to
          a YAML file and stored in the Nix store. The option
          {option}`objstore.config-file` will default to its path.

          If {option}`objstore.config-file` is set this option has no effect.

          See format details: <https://thanos.io/tip/thanos/storage.md/#configuring-access-to-object-storage>
        '';

        toArgs = _opt: _attrs: [ ];
      };

      objstore.config-file = {
        option = mkOption {
          default =
            if cfg.objstore.config == null then
              null
            else
              toString (format.generate "objstore.yaml" cfg.objstore.config);

          defaultText = literalExpression ''
            if config.services.thanos.<cmd>.objstore.config == null then null
            else toString (format.generate "objstore.yaml" config.services.thanos.<cmd>.objstore.config);
          '';

          description = ''
            Path to YAML file that contains object store configuration.

            See format details: <https://thanos.io/tip/thanos/storage.md/#configuring-access-to-object-storage>
          '';

          type = with types; nullOr str;
        };

        toArgs = _opt: path: optionToArgs "objstore.config-file" path;
      };
    };

    query = params.common cfg.query // {

      endpoints = mkListParam "endpoint" ''
        Addresses of statically configured Thanos API servers (repeatable).

        The scheme may be prefixed with 'dns+' or 'dnssrv+' to detect
        Thanos API servers through respective DNS lookups.
      '';

      grpc-client-server-name = mkParam types.str ''
        Server name to verify the hostname on the returned gRPC certificates.
        See <https://tools.ietf.org/html/rfc4366#section-3.1>
      '';

      grpc-client-tls-ca = mkParam types.str ''
        TLS CA Certificates to use to verify gRPC servers
      '';

      grpc-client-tls-cert = mkParam types.str ''
        TLS Certificates to use to identify this client to the server
      '';

      grpc-client-tls-key = mkParam types.str ''
        TLS Key for the client's certificate
      '';

      grpc-client-tls-secure = mkFlagParam ''
        Use TLS when talking to the gRPC server
      '';

      grpc-compression = mkParam types.str ''
        Compression algorithm to use for gRPC requests to other clients.
      '';

      query.auto-downsampling = mkFlagParam ''
        Enable automatic adjustment (step / 5) to what source of data should
        be used in store gateways if no
        `max_source_resolution` param is specified.
      '';

      query.default-evaluation-interval = mkParamDef types.str "1m" ''
        Set default evaluation interval for sub queries.
      '';

      query.max-concurrent = mkParamDef types.int 20 ''
        Maximum number of queries processed concurrently by query node.
      '';

      query.partial-response = mkFlagParam ''
        Enable partial response for queries if no
        `partial_response` param is specified.
      '';

      query.replica-labels = mkListParam "query.replica-label" ''
        Labels to treat as a replica indicator along which data is
        deduplicated.

        Still you will be able to query without deduplication using
        'dedup=false' parameter. Data includes time series, recording
        rules, and alerting rules.
      '';

      query.timeout = mkParamDef types.str "2m" ''
        Maximum time to process query by query node.
      '';

      selector-labels = mkAttrsParam "selector-label" ''
        Query selector labels that will be exposed in info endpoint.
      '';

      store.response-timeout = mkParamDef types.str "0ms" ''
        If a Store doesn't send any data in this specified duration then a
        Store will be ignored and partial data will be returned if it's
        enabled. `0` disables timeout.
      '';

      store.sd-dns-interval = mkParamDef types.str "30s" ''
        Interval between DNS resolutions.
      '';

      store.sd-files = mkListParam "store.sd-files" ''
        Path to files that contain addresses of store API servers. The path
        can be a glob pattern.
      '';

      store.sd-interval = mkParamDef types.str "5m" ''
        Refresh interval to re-read file SD files. It is used as a resync fallback.
      '';

      store.unhealthy-timeout = mkParamDef types.str "5m" ''
        Timeout before an unhealthy store is cleaned from the store UI page.
      '';

      web.external-prefix = mkParam types.str ''
        Static prefix for all HTML links and redirect URLs in the UI query web
        interface.

        Actual endpoints are still served on / or the
        {option}`web.route-prefix`. This allows thanos UI to be served
        behind a reverse proxy that strips a URL sub-path.
      '';

      web.prefix-header = mkParam types.str ''
        Name of HTTP request header used for dynamic prefixing of UI links and
        redirects.

        This option is ignored if the option
        `web.external-prefix` is set.

        Security risk: enable this option only if a reverse proxy in front of
        thanos is resetting the header.

        The setting `web.prefix-header="X-Forwarded-Prefix"`
        can be useful, for example, if Thanos UI is served via Traefik reverse
        proxy with `PathPrefixStrip` option enabled, which
        sends the stripped prefix value in `X-Forwarded-Prefix`
        header. This allows thanos UI to be served on a sub-path.
      '';

      web.route-prefix = mkParam types.str ''
        Prefix for API and UI endpoints.

        This allows thanos UI to be served on a sub-path. This option is
        analogous to {option}`web.route-prefix` of Promethus.
      '';
    };

    query-frontend = params.common cfg.query-frontend // {
      query-frontend.downstream-url = mkParamDef types.str "http://localhost:9090" ''
        URL of downstream Prometheus Query compatible API.
      '';
    };

    receive =
      params.common cfg.receive
      // params.objstore cfg.receive
      // {

        labels = mkAttrsParam "label" ''
          External labels to announce.

          This flag will be removed in the future when handling multiple tsdb
          instances is added.
        '';

        receive.grpc-compression = mkParam types.str ''
          Compression algorithm to use for gRPC requests to other receivers.
        '';

        remote-write.address = mkParamDef types.str "0.0.0.0:19291" ''
          Address to listen on for remote write requests.
        '';

        stateDir = mkStateDirParam "tsdb.path" "thanos-receive" ''
          Data directory relative to `/var/lib` of TSDB.
        '';

        tsdb.retention = mkParamDef types.str "15d" ''
          How long to retain raw samples on local storage.

          `0d` - disables this retention
        '';
      };

    rule =
      params.common cfg.rule
      // params.objstore cfg.rule
      // {

        alert.label-drop = mkListParam "alert.label-drop" ''
          Labels by name to drop before sending to alertmanager.

          This allows alert to be deduplicated on replica label.

          Similar Prometheus alert relabelling
        '';

        alert.query-url = mkParam types.str ''
          The external Thanos Query URL that would be set in all alerts 'Source' field.
        '';

        alertmanagers.send-timeout = mkParamDef types.str "10s" ''
          Timeout for sending alerts to alertmanager.
        '';

        alertmanagers.urls = mkListParam "alertmanagers.url" ''
          Alertmanager replica URLs to push firing alerts.

          Ruler claims success if push to at least one alertmanager from
          discovered succeeds. The scheme may be prefixed with
          `dns+` or `dnssrv+` to detect
          Alertmanager IPs through respective DNS lookups. The port defaults to
          `9093` or the SRV record's value. The URL path is
          used as a prefix for the regular Alertmanager API path.
        '';

        eval-interval = mkParamDef types.str "1m" ''
          The default evaluation interval to use.
        '';

        labels = mkAttrsParam "label" ''
          Labels to be applied to all generated metrics.

          Similar to external labels for Prometheus,
          used to identify ruler and its blocks as unique source.
        '';

        query.addresses = mkListParam "query" ''
          Addresses of statically configured query API servers.

          The scheme may be prefixed with `dns+` or
          `dnssrv+` to detect query API servers through
          respective DNS lookups.
        '';

        query.sd-dns-interval = mkParamDef types.str "30s" ''
          Interval between DNS resolutions.
        '';

        query.sd-files = mkListParam "query.sd-files" ''
          Path to file that contain addresses of query peers.
          The path can be a glob pattern.
        '';

        query.sd-interval = mkParamDef types.str "5m" ''
          Refresh interval to re-read file SD files. (used as a fallback)
        '';

        rule-files = mkListParam "rule-file" ''
          Rule files that should be used by rule manager. Can be in glob format.
        '';

        stateDir = mkStateDirParam "data-dir" "thanos-rule" ''
          Data directory relative to `/var/lib`.
        '';

        tsdb.block-duration = mkParamDef types.str "2h" ''
          Block duration for TSDB block.
        '';

        tsdb.retention = mkParamDef types.str "48h" ''
          Block retention time on local disk.
        '';

        web.external-prefix = mkParam types.str ''
          Static prefix for all HTML links and redirect URLs in the UI query web
          interface.

          Actual endpoints are still served on / or the
          {option}`web.route-prefix`. This allows thanos UI to be served
          behind a reverse proxy that strips a URL sub-path.
        '';

        web.prefix-header = mkParam types.str ''
          Name of HTTP request header used for dynamic prefixing of UI links and
          redirects.

          This option is ignored if the option
          {option}`web.external-prefix` is set.

          Security risk: enable this option only if a reverse proxy in front of
          thanos is resetting the header.

          The header `X-Forwarded-Prefix` can be useful, for
          example, if Thanos UI is served via Traefik reverse proxy with
          `PathPrefixStrip` option enabled, which sends the
          stripped prefix value in `X-Forwarded-Prefix`
          header. This allows thanos UI to be served on a sub-path.
        '';

        web.route-prefix = mkParam types.str ''
          Prefix for API and UI endpoints.

          This allows thanos UI to be served on a sub-path.

          This option is analogous to `--web.route-prefix` of Promethus.
        '';
      };

    sidecar =
      params.common cfg.sidecar
      // params.objstore cfg.sidecar
      // {

        prometheus.url = mkParamDef types.str "http://localhost:9090" ''
          URL at which to reach Prometheus's API.

          For better performance use local network.
        '';

        reloader.config-envsubst-file = mkParam types.str ''
          Output file for environment variable substituted config file.
        '';

        reloader.config-file = mkParam types.str ''
          Config file watched by the reloader.
        '';

        reloader.rule-dirs = mkListParam "reloader.rule-dir" ''
          Rule directories for the reloader to refresh.
        '';

        tsdb.path = {
          option = mkOption {
            default = "/var/lib/${config.services.prometheus.stateDir}/data";
            defaultText = literalExpression ''"/var/lib/''${config.services.prometheus.stateDir}/data"'';

            description = ''
              Data directory of TSDB.
            '';

            type = types.str;
          };

          toArgs = optionToArgs;
        };

      };

    store =
      params.common cfg.store
      // params.objstore cfg.store
      // {

        block-sync-concurrency = mkParamDef types.int 20 ''
          Number of goroutines to use when syncing blocks from object storage.
        '';

        chunk-pool-size = mkParamDef types.str "2GB" ''
          Maximum size of concurrently allocatable bytes for chunks.
        '';

        index-cache-size = mkParamDef types.str "250MB" ''
          Maximum size of items held in the index cache.
        '';

        max-time = mkParamDef types.str "9999-12-31T23:59:59Z" ''
          End of time range limit to serve.

          Thanos Store serves only blocks, which happened earlier than this
          value. Option can be a constant time in RFC3339 format or time duration
          relative to current time, such as -1d or 2h45m. Valid duration units are
          ms, s, m, h, d, w, y.
        '';

        min-time = mkParamDef types.str "0000-01-01T00:00:00Z" ''
          Start of time range limit to serve.

          Thanos Store serves only metrics, which happened later than this
          value. Option can be a constant time in RFC3339 format or time duration
          relative to current time, such as -1d or 2h45m. Valid duration units are
          ms, s, m, h, d, w, y.
        '';

        stateDir = mkStateDirParam "data-dir" "thanos-store" ''
          Data directory relative to `/var/lib`
          in which to cache remote blocks.
        '';

        store.grpc.series-max-concurrency = mkParamDef types.int 20 ''
          Maximum number of concurrent Series calls.
        '';

        store.limits.request-samples = mkParamDef types.int 0 ''
          The maximum samples allowed for a single Series request.
          The Series call fails if this limit is exceeded.

          `0` means no limit.

          NOTE: For efficiency the limit is internally implemented as 'chunks limit'
          considering each chunk contains a maximum of 120 samples.
        '';

        sync-block-duration = mkParamDef types.str "3m" ''
          Repeat interval for syncing the blocks between local and remote view.
        '';
      };

    tracing = cfg: {
      tracing.config = {
        option = nullOpt format.type ''
          Tracing configuration.

          When not `null` the attribute set gets converted to
          a YAML file and stored in the Nix store. The option
          {option}`tracing.config-file` will default to its path.

          If {option}`tracing.config-file` is set this option has no effect.

          See format details: <https://thanos.io/tip/thanos/tracing.md/#configuration>
        '';

        toArgs = _opt: _attrs: [ ];
      };

      tracing.config-file = {
        option = mkOption {
          default =
            if cfg.tracing.config == null then
              null
            else
              toString (format.generate "tracing.yaml" cfg.tracing.config);

          defaultText = literalExpression ''
            if config.services.thanos.<cmd>.tracing.config == null then null
            else toString (format.generate "tracing.yaml" config.services.thanos.<cmd>.tracing.config);
          '';

          description = ''
            Path to YAML file that contains tracing configuration.

            See format details: <https://thanos.io/tip/thanos/tracing.md/#configuration>
          '';

          type = with types; nullOr str;
        };

        toArgs = _opt: path: optionToArgs "tracing.config-file" path;
      };
    };

  };

  assertRelativeStateDir = cmd: {
    assertions = [
      {
        assertion = !hasPrefix "/" cfg.${cmd}.stateDir;

        message =
          "The option services.thanos.${cmd}.stateDir should not be an absolute directory."
          + " It should be a directory relative to /var/lib.";
      }
    ];
  };

in
{

  options.services.thanos = {

    package = mkPackageOption pkgs "thanos" { };

    compact = paramsToOptions params.compact // {
      enable = mkEnableOption "the Thanos compactor which continuously compacts blocks in an object store bucket";
      arguments = mkArgumentsOption "compact";
    };

    downsample = paramsToOptions params.downsample // {
      enable = mkEnableOption "the Thanos downsampler which continuously downsamples blocks in an object store bucket";
      arguments = mkArgumentsOption "downsample";
    };

    query = paramsToOptions params.query // {
      enable = mkEnableOption (
        "the Thanos query node exposing PromQL enabled Query API "
        + "with data retrieved from multiple store nodes"
      );

      arguments = mkArgumentsOption "query";
    };

    query-frontend = paramsToOptions params.query-frontend // {
      enable = mkEnableOption "the Thanos query frontend implements a service deployed in front of queriers to
          improve query parallelization and caching.";

      arguments = mkArgumentsOption "query-frontend";
    };

    receive = paramsToOptions params.receive // {
      enable = mkEnableOption "the Thanos receiver which accept Prometheus remote write API requests and write to local tsdb";
      arguments = mkArgumentsOption "receive";
    };

    rule = paramsToOptions params.rule // {
      enable = mkEnableOption (
        "the Thanos ruler service which evaluates Prometheus rules against"
        + " given Query nodes, exposing Store API and storing old blocks in bucket"
      );

      arguments = mkArgumentsOption "rule";
    };

    sidecar = paramsToOptions params.sidecar // {
      enable = mkEnableOption "the Thanos sidecar for Prometheus server";
      arguments = mkArgumentsOption "sidecar";
    };

    store = paramsToOptions params.store // {
      enable = mkEnableOption "the Thanos store node giving access to blocks in a bucket provider";
      arguments = mkArgumentsOption "store";
    };
  };

  config = mkMerge [

    (mkIf cfg.sidecar.enable {
      assertions = [
        {
          assertion = config.services.prometheus.enable;
          message = "Please enable services.prometheus when enabling services.thanos.sidecar.";
        }
        {
          assertion =
            !(
              config.services.prometheus.globalConfig.external_labels == null
              || config.services.prometheus.globalConfig.external_labels == { }
            );

          message =
            "services.thanos.sidecar requires uniquely identifying external labels "
            + "to be configured in the Prometheus server. "
            + "Please set services.prometheus.globalConfig.external_labels.";
        }
      ];

      systemd.services.thanos-sidecar = {
        after = [
          "network.target"
          "prometheus.service"
        ];

        serviceConfig = {
          ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
          ExecStart = thanos "sidecar";
          Restart = "always";
          User = "prometheus";
        };

        wantedBy = [ "multi-user.target" ];
      };
    })

    (mkIf cfg.store.enable (mkMerge [
      (assertRelativeStateDir "store")
      {
        systemd.services.thanos-store = {
          after = [ "network.target" ];

          serviceConfig = {
            DynamicUser = true;
            ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
            ExecStart = thanos "store";
            Restart = "always";
            StateDirectory = cfg.store.stateDir;
          };

          wantedBy = [ "multi-user.target" ];
        };
      }
    ]))

    (mkIf cfg.query.enable {
      systemd.services.thanos-query = {
        after = [ "network.target" ];

        serviceConfig = {
          DynamicUser = true;
          ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
          ExecStart = thanos "query";
          Restart = "always";
        };

        wantedBy = [ "multi-user.target" ];
      };
    })

    (mkIf cfg.query-frontend.enable {
      systemd.services.thanos-query-frontend = {
        after = [ "network.target" ];

        serviceConfig = {
          DynamicUser = true;
          ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
          ExecStart = thanos "query-frontend";
          Restart = "always";
        };

        wantedBy = [ "multi-user.target" ];
      };
    })

    (mkIf cfg.rule.enable (mkMerge [
      (assertRelativeStateDir "rule")
      {
        systemd.services.thanos-rule = {
          after = [ "network.target" ];

          serviceConfig = {
            DynamicUser = true;
            ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
            ExecStart = thanos "rule";
            Restart = "always";
            StateDirectory = cfg.rule.stateDir;
          };

          wantedBy = [ "multi-user.target" ];
        };
      }
    ]))

    (mkIf cfg.compact.enable (mkMerge [
      (assertRelativeStateDir "compact")
      {
        systemd.services.thanos-compact =
          let
            wait = cfg.compact.startAt == null;
          in
          {
            after = [ "network.target" ];

            serviceConfig = {
              DynamicUser = true;
              ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
              ExecStart = thanos "compact";
              Restart = if wait then "always" else "no";
              StateDirectory = cfg.compact.stateDir;
              Type = if wait then "simple" else "oneshot";
            };

            wantedBy = [ "multi-user.target" ];
          }
          // optionalAttrs (!wait) { inherit (cfg.compact) startAt; };
      }
    ]))

    (mkIf cfg.downsample.enable (mkMerge [
      (assertRelativeStateDir "downsample")
      {
        systemd.services.thanos-downsample = {
          after = [ "network.target" ];

          serviceConfig = {
            DynamicUser = true;
            ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
            ExecStart = thanos "downsample";
            Restart = "always";
            StateDirectory = cfg.downsample.stateDir;
          };

          wantedBy = [ "multi-user.target" ];
        };
      }
    ]))

    (mkIf cfg.receive.enable (mkMerge [
      (assertRelativeStateDir "receive")
      {
        systemd.services.thanos-receive = {
          after = [ "network.target" ];

          serviceConfig = {
            DynamicUser = true;
            ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
            ExecStart = thanos "receive";
            Restart = "always";
            StateDirectory = cfg.receive.stateDir;
          };

          wantedBy = [ "multi-user.target" ];
        };
      }
    ]))

  ];
}
