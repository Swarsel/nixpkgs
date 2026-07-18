{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.cloudflare-ddns;

  boolToString = b: if b then "true" else "false";
  formatList = l: lib.concatStringsSep "," l;
in
{
  options.services.cloudflare-ddns = {
    enable = lib.mkEnableOption "Cloudflare Dynamic DNS service";
    package = lib.mkPackageOption pkgs "cloudflare-ddns" { };

    cacheExpiration = lib.mkOption {
      default = "6h";

      description = ''
        Duration for which API responses (like Zone ID, Record IDs) are cached.
        Uses Go's duration format (e.g., "6h", "1h30m").
      '';

      type = lib.types.str;
    };

    credentialsFile = lib.mkOption {
      description = ''
        Path to a file containing the Cloudflare API authentication token.
        The file content should be in the format `CLOUDFLARE_API_TOKEN=YOUR_SECRET_TOKEN`.
        The service user needs read access to this file.
        Ensure permissions are secure (e.g., `0400` or `0440`) and ownership is appropriate
        Using `CLOUDFLARE_API_TOKEN` is preferred over the deprecated `CF_API_TOKEN`.
      '';

      example = "/run/secrets/cloudflare-ddns-token";
      type = lib.types.path;
    };

    deleteOnStop = lib.mkOption {
      default = false;

      description = ''
        Whether to delete the managed DNS records and clear WAF lists when the service is stopped gracefully.
        Warning: Setting this to true with `updateCron = "@once"` will cause immediate deletion.
      '';

      type = lib.types.bool;
    };

    detectionTimeout = lib.mkOption {
      default = "5s";
      description = "Timeout for detecting the public IP address.";
      type = lib.types.str;
    };

    domains = lib.mkOption {
      default = [ ];

      description = ''
        List of domain names (FQDNs) to manage. Wildcards like `*.example.com` are supported.
        These domains will be managed for both IPv4 and IPv6 unless overridden by
        `ip4Domains` or `ip6Domains`, or if the respective providers are disabled.
        This corresponds to the `DOMAINS` environment variable.
      '';

      example = [
        "home.example.com"
        "*.dynamic.example.org"
      ];

      type = lib.types.listOf lib.types.str;
    };

    group = lib.mkOption {
      default = "cloudflare-ddns";
      description = "Group under which the service runs.";
      type = lib.types.str;
    };

    healthchecks = lib.mkOption {
      default = null;
      description = "URL for Healthchecks.io monitoring endpoint (optional).";
      example = "https://hc-ping.com/your-uuid";
      type = lib.types.nullOr lib.types.str;
    };

    ip4Domains = lib.mkOption {
      default = null;

      description = ''
        Explicit list of domains to manage only for IPv4. If set, overrides `domains` for IPv4.
        Corresponds to the `IP4_DOMAINS` environment variable.
      '';

      example = [ "ipv4.example.com" ];
      type = lib.types.nullOr (lib.types.listOf lib.types.str);
    };

    ip6Domains = lib.mkOption {
      default = null;

      description = ''
        Explicit list of domains to manage only for IPv6. If set, overrides `domains` for IPv6.
        Corresponds to the `IP6_DOMAINS` environment variable.
      '';

      example = [ "ipv6.example.com" ];
      type = lib.types.nullOr (lib.types.listOf lib.types.str);
    };

    provider = {
      ipv4 = lib.mkOption {
        default = "cloudflare.trace";

        description = ''
          IP detection provider for IPv4. Common values: `cloudflare.trace`, `cloudflare.doh`, `local`, `url:URL`, `none`.
          Use `none` to disable IPv4 updates.
          See cloudflare-ddns documentation for all options.
        '';

        type = lib.types.str;
      };

      ipv6 = lib.mkOption {
        default = "cloudflare.trace";

        description = ''
          IP detection provider for IPv6. Common values: `cloudflare.trace`, `cloudflare.doh`, `local`, `url:URL`, `none`.
          Use `none` to disable IPv6 updates.
          See cloudflare-ddns documentation for all options.
        '';

        type = lib.types.str;
      };
    };

    proxied = lib.mkOption {
      default = "false";

      description = ''
        Whether the managed DNS records should be proxied through Cloudflare ('orange cloud').
        Accepts boolean values (`true`, `false`) or a domain expression.
        See cloudflare-ddns documentation for expression syntax (e.g., "is(a.com) || sub(b.org)").
      '';

      example = "true";
      type = lib.types.str;
    };

    recordComment = lib.mkOption {
      default = "";
      description = "Comment to add to managed DNS records.";
      type = lib.types.str;
    };

    shoutrrr = lib.mkOption {
      default = null;
      description = "List of Shoutrrr notification service URLs (optional).";

      example = [
        "discord://token@id"
        "gotify://host/token"
      ];

      type = lib.types.nullOr (lib.types.listOf lib.types.str);
    };

    ttl = lib.mkOption {
      default = 1;

      description = ''
        Time To Live (TTL) for the DNS records in seconds.
        Must be 1 (for automatic) or between 30 and 86400.
      '';

      type = lib.types.ints.positive;
    };

    updateCron = lib.mkOption {
      default = "@every 5m";

      description = ''
        Cron expression for how often to check and update IPs.
        Use "@once" to run only once and then exit.
      '';

      example = "@hourly";
      type = lib.types.str;
    };

    updateOnStart = lib.mkOption {
      default = true;
      description = "Whether to perform an update check immediately on service start.";
      type = lib.types.bool;
    };

    updateTimeout = lib.mkOption {
      default = "30s";
      description = "Timeout for updating records via the Cloudflare API.";
      type = lib.types.str;
    };

    uptimeKuma = lib.mkOption {
      default = null;
      description = "URL for Uptime Kuma push monitor endpoint (optional).";
      example = "https://status.example.com/api/push/tag?status=up&msg=OK&ping=";
      type = lib.types.nullOr lib.types.str;
    };

    user = lib.mkOption {
      default = "cloudflare-ddns";
      description = "User account under which the service runs.";
      type = lib.types.str;
    };

    wafListDescription = lib.mkOption {
      default = "";
      description = "Description for managed WAF lists (used when creating or verifying lists).";
      type = lib.types.str;
    };

    wafLists = lib.mkOption {
      default = [ ];

      description = ''
        List of WAF IP Lists to manage, in the format `account-id/list-name`.
        (Experimental feature as of cloudflare-ddns 1.14.0).
      '';

      example = [ "YOUR_ACCOUNT_ID/allowed_dynamic_ips" ];
      type = lib.types.listOf lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.ttl == 1 || (cfg.ttl >= 30 && cfg.ttl <= 86400);
        message = "services.cloudflare-ddns.ttl must be 1 or between 30 and 86400";
      }
      {
        assertion = cfg.updateCron == "@once" -> !cfg.deleteOnStop;
        message = "services.cloudflare-ddns.deleteOnStop cannot be true when updateCron is \"@once\"";
      }
      {
        assertion =
          cfg.domains != [ ] || cfg.ip4Domains != null || cfg.ip6Domains != null || cfg.wafLists != [ ];

        message = "services.cloudflare-ddns requires at least one domain (domains, ip4Domains, ip6Domains) or WAF list (wafLists) to be specified";
      }
      {
        assertion = cfg.provider.ipv4 != "none" || cfg.provider.ipv6 != "none";
        message = "services.cloudflare-ddns requires at least one provider (ipv4 or ipv6) to be enabled (not 'none')";
      }
    ];

    systemd.services.cloudflare-ddns = {
      after = [ "network-online.target" ];
      description = "Cloudflare Dynamic DNS Client Service (favonia)";

      serviceConfig = {
        Environment =
          let
            toEnv = name: value: "${name}=\"${toString value}\"";
            toEnvList = name: value: "${name}=\"${formatList value}\"";
            toEnvBool = name: value: "${name}=\"${boolToString value}\"";
            toEnvMaybe =
              pred: name: value:
              lib.optionalString pred (toEnv name value);
            toEnvMaybeList =
              pred: name: value:
              lib.optionalString pred (toEnvList name value);
          in
          lib.filter (envVar: envVar != "") [
            (toEnvList "DOMAINS" cfg.domains)
            (toEnvMaybeList (cfg.ip4Domains != null) "IP4_DOMAINS" cfg.ip4Domains)
            (toEnvMaybeList (cfg.ip6Domains != null) "IP6_DOMAINS" cfg.ip6Domains)

            (toEnv "IP4_PROVIDER" cfg.provider.ipv4)
            (toEnv "IP6_PROVIDER" cfg.provider.ipv6)

            (toEnvMaybeList (cfg.wafLists != [ ]) "WAF_LISTS" cfg.wafLists)
            (toEnvMaybe (cfg.wafListDescription != "") "WAF_LIST_DESCRIPTION" cfg.wafListDescription)

            (toEnv "UPDATE_CRON" cfg.updateCron)
            (toEnvBool "UPDATE_ON_START" cfg.updateOnStart)
            (toEnvBool "DELETE_ON_STOP" cfg.deleteOnStop)
            (toEnv "CACHE_EXPIRATION" cfg.cacheExpiration)

            (toEnv "TTL" cfg.ttl)
            (toEnv "PROXIED" cfg.proxied)
            (toEnvMaybe (cfg.recordComment != "") "RECORD_COMMENT" cfg.recordComment)

            (toEnv "DETECTION_TIMEOUT" cfg.detectionTimeout)
            (toEnv "UPDATE_TIMEOUT" cfg.updateTimeout)

            (toEnvMaybe (cfg.healthchecks != null) "HEALTHCHECKS" cfg.healthchecks)
            (toEnvMaybe (cfg.uptimeKuma != null) "UPTIMEKUMA" cfg.uptimeKuma)
            (toEnvMaybeList (cfg.shoutrrr != null) "SHOUTRRR" (lib.concatStringsSep "\n" cfg.shoutrrr))
          ];

        EnvironmentFile = cfg.credentialsFile;
        ExecStart = lib.getExe cfg.package;
        Group = cfg.group;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        Restart = "on-failure";
        RestartSec = "30s";

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];

        User = cfg.user;
        WorkingDirectory = "/var/lib/${cfg.user}";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };

    systemd.tmpfiles.settings."cloudflare-ddns" = {
      "/var/lib/${cfg.user}".d = {
        group = cfg.group;
        mode = "0750";
        user = cfg.user;
      };
    };

    users.groups.${cfg.group} = { };

    users.users.${cfg.user} = {
      description = "Cloudflare DDNS service user";
      group = cfg.group;
      home = "/var/lib/${cfg.user}";
      isSystemUser = true;
    };
  };

  meta.maintainers = with lib.maintainers; [
    shokerplz
  ];
}
