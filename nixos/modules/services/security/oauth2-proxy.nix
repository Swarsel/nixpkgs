{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.oauth2-proxy;

  # oauth2-proxy provides many options that are only relevant if you are using
  # a certain provider. This set maps from provider name to a function that
  # takes the configuration and returns a string that can be inserted into the
  # command-line to launch oauth2-proxy.
  providerSpecificOptions = {
    azure = cfg: {
      azure-tenant = cfg.azure.tenant;
      resource = cfg.azure.resource;
    };

    github = cfg: {
      github = {
        inherit (cfg.github) org team;
      };
    };

    google = cfg: {
      google =
        with cfg.google;
        lib.optionalAttrs (groups != [ ]) {
          admin-email = adminEmail;
          group = groups;
          service-account = serviceAccountJSON;
        };
    };
  };

  authenticatedEmailsFile = pkgs.writeText "authenticated-emails" cfg.email.addresses;

  getProviderOptions = cfg: provider: providerSpecificOptions.${provider} or (_: { }) cfg;

  allConfig =
    with cfg;
    {
      inherit (cfg) provider scope upstream;
      approval-prompt = approvalPrompt;
      basic-auth-password = basicAuthPassword;
      client-id = clientID;
      client-secret-file = if clientSecretFile != null then "%d/client-secret" else null;

      cookie = {
        inherit (cookie)
          domain
          secure
          expire
          name
          refresh
          ;

        httponly = cookie.httpOnly;
        secret-file = if cookie.secretFile != null then "%d/cookie-secret" else null;
      };

      custom-templates-dir = customTemplatesDir;
      email-domain = email.domains;
      htpasswd-file = htpasswd.file;
      http-address = httpAddress;
      login-url = loginURL;
      oidc-issuer-url = oidcIssuerUrl;
      pass-access-token = passAccessToken;
      pass-basic-auth = passBasicAuth;
      pass-host-header = passHostHeader;
      profile-url = profileURL;
      proxy-prefix = proxyPrefix;
      redeem-url = redeemURL;
      redirect-url = redirectURL;
      request-logging = requestLogging;
      reverse-proxy = reverseProxy;
      set-xauthrequest = setXauthrequest;
      signature-key = signatureKey;
      skip-auth-regex = skipAuthRegexes;
      trusted-proxy-ip = trustedProxyIP;
      validate-url = validateURL;
    }
    // lib.optionalAttrs (cfg.email.addresses != null) {
      authenticated-emails-file = authenticatedEmailsFile;
    }
    // lib.optionalAttrs (cfg.passBasicAuth) {
      basic-auth-password = cfg.basicAuthPassword;
    }
    // lib.optionalAttrs (cfg.htpasswd.file != null) {
      display-htpasswd-form = cfg.htpasswd.displayForm;
    }
    // lib.optionalAttrs tls.enable {
      https-address = tls.httpsAddress;
      tls-cert-file = tls.certificate;
      tls-key-file = tls.key;
    }
    // (getProviderOptions cfg cfg.provider)
    // cfg.extraConfig;

  mapConfig =
    key: attr:
    lib.optionalString (attr != null && attr != [ ]) (
      if lib.isDerivation attr then
        mapConfig key (toString attr)
      else if (builtins.typeOf attr) == "set" then
        lib.concatStringsSep " " (lib.mapAttrsToList (name: value: mapConfig (key + "-" + name) value) attr)
      else if (builtins.typeOf attr) == "list" then
        lib.concatMapStringsSep " " (mapConfig key) attr
      else if (builtins.typeOf attr) == "bool" then
        "--${key}=${lib.boolToString attr}"
      else if (builtins.typeOf attr) == "string" then
        "--${key}='${attr}'"
      else
        "--${key}=${toString attr}"
    );

  configString = lib.concatStringsSep " " (lib.mapAttrsToList mapConfig allConfig);
in
{
  imports = [
    (lib.mkRenamedOptionModule [ "services" "oauth2_proxy" ] [ "services" "oauth2-proxy" ])
    (lib.mkRemovedOptionModule [ "services" "oauth2-proxy" "clientSecret" ] ''
      This option has been removed as it made the client secret world-readable.
      Use services.oauth2-proxy.clientSecretFile instead.
    '')
    (lib.mkRemovedOptionModule [ "services" "oauth2-proxy" "cookie" "secret" ] ''
      This option has been removed as it made the cookie secret world-readable.
      Use services.oauth2-proxy.cookie.secretFile instead.
    '')
  ];

  options.services.oauth2-proxy = {
    enable = lib.mkEnableOption "oauth2-proxy";
    package = lib.mkPackageOption pkgs "oauth2-proxy" { };

    approvalPrompt = lib.mkOption {
      default = "force";

      description = ''
        OAuth approval_prompt.
      '';

      type = lib.types.enum [
        "force"
        "auto"
      ];
    };

    azure = {
      resource = lib.mkOption {
        description = ''
          The resource that is protected.
        '';

        type = lib.types.str;
      };

      tenant = lib.mkOption {
        default = "common";

        description = ''
          Go to a tenant-specific or common (tenant-independent) endpoint.
        '';

        type = lib.types.str;
      };
    };

    basicAuthPassword = lib.mkOption {
      default = null;

      description = ''
        The password to set when passing the HTTP Basic Auth header.
      '';

      type = lib.types.nullOr lib.types.str;
    };

    clientID = lib.mkOption {
      default = null;

      description = ''
        The OAuth Client ID.
      '';

      example = "123456.apps.googleusercontent.com";
      type = lib.types.nullOr lib.types.str;
    };

    clientSecretFile = lib.mkOption {
      default = null;

      description = ''
        The path to a file containing the OAuth Client Secret.
      '';

      example = "/run/keys/oauth2-client-secret";
      type = lib.types.nullOr lib.types.path;
    };

    cookie = {
      domain = lib.mkOption {
        default = null;

        description = ''
          Optional cookie domains to force cookies to (ie: `.yourcompany.com`).
          The longest domain matching the request's host will be used (or the shortest
          cookie domain if there is no match).
        '';

        example = ".yourcompany.com";
        type = lib.types.nullOr lib.types.str;
      };

      expire = lib.mkOption {
        default = "168h0m0s";

        description = ''
          Expire timeframe for cookie.
        '';

        type = lib.types.str;
      };

      httpOnly = lib.mkOption {
        default = true;

        description = ''
          Set HttpOnly cookie flag.
        '';

        type = lib.types.bool;
      };

      name = lib.mkOption {
        default = "_oauth2_proxy";

        description = ''
          The name of the cookie that the oauth_proxy creates.
        '';

        type = lib.types.str;
      };

      refresh = lib.mkOption {
        default = null;

        description = ''
          Refresh the cookie after this duration; 0 to disable.
        '';

        example = "168h0m0s";
        # XXX: Unclear what the behavior is when this is not specified.
        type = lib.types.nullOr lib.types.str;
      };

      secretFile = lib.mkOption {
        default = null;

        description = ''
          The path to a file containing the seed string for secure cookies.
        '';

        example = "/run/keys/oauth2-cookie-secret";
        type = lib.types.nullOr lib.types.path;
      };

      secure = lib.mkOption {
        default = true;

        description = ''
          Set secure (HTTPS) cookie flag.
        '';

        type = lib.types.bool;
      };
    };

    customTemplatesDir = lib.mkOption {
      default = null;

      description = ''
        Path to custom HTML templates.
      '';

      type = lib.types.nullOr lib.types.path;
    };

    # XXX: Not clear whether these two options are mutually exclusive or not.
    email = {
      addresses = lib.mkOption {
        default = null;

        description = ''
          Line-separated email addresses that are allowed to authenticate.
        '';

        type = lib.types.nullOr lib.types.lines;
      };

      domains = lib.mkOption {
        default = [ ];

        description = ''
          Authenticate emails with the specified domains. Use
          `*` to authenticate any email.
        '';

        type = lib.types.listOf lib.types.str;
      };
    };

    extraConfig = lib.mkOption {
      default = { };

      description = ''
        Extra config to pass to oauth2-proxy.
      '';

      type = lib.types.attrsOf lib.types.anything;
    };

    github = {
      org = lib.mkOption {
        default = null;

        description = ''
          Restrict logins to members of this organisation.
        '';

        type = lib.types.nullOr lib.types.str;
      };

      team = lib.mkOption {
        default = null;

        description = ''
          Restrict logins to members of this team.
        '';

        type = lib.types.nullOr lib.types.str;
      };
    };

    google = {
      adminEmail = lib.mkOption {
        description = ''
          The Google Admin to impersonate for API calls.

          Only users with access to the Admin APIs can access the Admin SDK
          Directory API, thus the service account needs to impersonate one of
          those users to access the Admin SDK Directory API.

          See <https://developers.google.com/admin-sdk/directory/v1/guides/delegation#delegate_domain-wide_authority_to_your_service_account>.
        '';

        type = lib.types.str;
      };

      groups = lib.mkOption {
        default = [ ];

        description = ''
          Restrict logins to members of these Google groups.
        '';

        type = lib.types.listOf lib.types.str;
      };

      serviceAccountJSON = lib.mkOption {
        description = ''
          The path to the service account JSON credentials.
        '';

        type = lib.types.path;
      };
    };

    htpasswd = {
      displayForm = lib.mkOption {
        default = true;

        description = ''
          Display username / password login form if an htpasswd file is provided.
        '';

        type = lib.types.bool;
      };

      file = lib.mkOption {
        default = null;

        description = ''
          Additionally authenticate against a htpasswd file. Entries must be
          created with `htpasswd -s` for SHA encryption.
        '';

        type = lib.types.nullOr lib.types.path;
      };
    };

    ####################################################
    # OAUTH2 PROXY configuration
    httpAddress = lib.mkOption {
      default = "http://127.0.0.1:4180";

      description = ''
        HTTPS listening address.  This module does not expose the port by
        default. If you want this URL to be accessible to other machines, please
        add the port to `networking.firewall.allowedTCPPorts`.
      '';

      type = lib.types.str;
    };

    keyFile = lib.mkOption {
      default = null;

      description = ''
        oauth2-proxy allows passing sensitive configuration via environment variables.
        Make a file that contains lines like
        OAUTH2_PROXY_CLIENT_SECRET=asdfasdfasdf.apps.googleuserscontent.com
        and specify the path here.
      '';

      example = "/run/keys/oauth2-proxy";
      type = lib.types.nullOr lib.types.path;
    };

    loginURL = lib.mkOption {
      default = null;

      description = ''
        Authentication endpoint.

        You only need to set this if you are using a self-hosted provider (e.g.
        Github Enterprise). If you're using a publicly hosted provider
        (e.g github.com), then the default works.
      '';

      example = "https://provider.example.com/oauth/authorize";
      type = lib.types.nullOr lib.types.str;
    };

    oidcIssuerUrl = lib.mkOption {
      default = null;

      description = ''
        The OAuth issuer URL.
      '';

      example = "https://login.microsoftonline.com/{TENANT_ID}/v2.0";
      type = lib.types.nullOr lib.types.str;
    };

    passAccessToken = lib.mkOption {
      default = false;

      description = ''
        Pass OAuth access_token to upstream via X-Forwarded-Access-Token header.
      '';

      type = lib.types.bool;
    };

    passBasicAuth = lib.mkOption {
      default = true;

      description = ''
        Pass HTTP Basic Auth, X-Forwarded-User and X-Forwarded-Email information to upstream.
      '';

      type = lib.types.bool;
    };

    passHostHeader = lib.mkOption {
      default = true;

      description = ''
        Pass the request Host Header to upstream.
      '';

      type = lib.types.bool;
    };

    profileURL = lib.mkOption {
      default = null;

      description = ''
        Profile access endpoint.
      '';

      type = lib.types.nullOr lib.types.str;
    };

    ##############################################
    # PROVIDER configuration
    # Taken from: https://github.com/oauth2-proxy/oauth2-proxy/blob/master/providers/providers.go
    provider = lib.mkOption {
      default = "google";

      description = ''
        OAuth provider.
      '';

      type = lib.types.enum [
        "adfs"
        "azure"
        "bitbucket"
        "digitalocean"
        "facebook"
        "github"
        "gitlab"
        "google"
        "keycloak"
        "keycloak-oidc"
        "linkedin"
        "login.gov"
        "nextcloud"
        "oidc"
      ];
    };

    proxyPrefix = lib.mkOption {
      default = "/oauth2";

      description = ''
        The url root path that this proxy should be nested under.
      '';

      type = lib.types.str;
    };

    redeemURL = lib.mkOption {
      default = null;

      description = ''
        Token redemption endpoint.

        You only need to set this if you are using a self-hosted provider (e.g.
        Github Enterprise). If you're using a publicly hosted provider
        (e.g github.com), then the default works.
      '';

      example = "https://provider.example.com/oauth/token";
      type = lib.types.nullOr lib.types.str;
    };

    redirectURL = lib.mkOption {
      default = null;

      description = ''
        The OAuth2 redirect URL.
      '';

      example = "https://internalapp.yourcompany.com/oauth2/callback";
      # XXX: jml suspects this is always necessary, but the command-line
      # doesn't require it so making it optional.
      type = lib.types.nullOr lib.types.str;
    };

    requestLogging = lib.mkOption {
      default = true;

      description = ''
        Log requests to stdout.
      '';

      type = lib.types.bool;
    };

    reverseProxy = lib.mkOption {
      default = false;

      description = ''
        In case when running behind a reverse proxy, controls whether headers
        like `X-Real-Ip` are accepted. Usage behind a reverse
        proxy will require this flag to be set to avoid logging the reverse
        proxy IP address.
      '';

      type = lib.types.bool;
    };

    ####################################################
    # UNKNOWN
    # XXX: Is this mandatory? Is it part of another group? Is it part of the provider specification?
    scope = lib.mkOption {
      default = null;

      description = ''
        OAuth scope specification.
      '';

      # XXX: jml suspects this is always necessary, but the command-line
      # doesn't require it so making it optional.
      type = lib.types.nullOr lib.types.str;
    };

    setXauthrequest = lib.mkOption {
      default = false;

      description = ''
        Set X-Auth-Request-User and X-Auth-Request-Email response headers (useful in Nginx auth_request mode). Setting this to 'null' means using the upstream default (false).
      '';

      type = lib.types.nullOr lib.types.bool;
    };

    signatureKey = lib.mkOption {
      default = null;

      description = ''
        GAP-Signature request signature key.
      '';

      example = "sha1:secret0";
      type = lib.types.nullOr lib.types.str;
    };

    skipAuthRegexes = lib.mkOption {
      default = [ ];

      description = ''
        Skip authentication for requests matching any of these regular
        expressions.
      '';

      type = lib.types.listOf lib.types.str;
    };

    tls = {
      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to serve over TLS.
        '';

        type = lib.types.bool;
      };

      certificate = lib.mkOption {
        description = ''
          Path to certificate file.
        '';

        type = lib.types.path;
      };

      httpsAddress = lib.mkOption {
        default = ":443";

        description = ''
          `addr:port` to listen on for HTTPS clients.

          Remember to add `port` to
          `allowedTCPPorts` if you want other machines to be
          able to connect to it.
        '';

        type = lib.types.str;
      };

      key = lib.mkOption {
        description = ''
          Path to private key file.
        '';

        type = lib.types.path;
      };
    };

    trustedProxyIP = lib.mkOption {
      default = [ ];

      description = ''
        List of IPs or CIDR ranges allowed to supply X-Forwarded-* headers when reverseProxy is enabled.
        If not set, OAuth2 Proxy preserves backwards compatibility by trusting all source IPs (0.0.0.0/0, ::/0) and logs a warning at startup.
        Configure this to your reverse proxy addresses to prevent forwarded header spoofing.
      '';

      type = with lib.types; listOf str;
    };

    ####################################################
    # UPSTREAM Configuration
    upstream = lib.mkOption {
      default = [ ];

      description = ''
        The http url(s) of the upstream endpoint or `file://`
        paths for static files. Routing is based on the path.
      '';

      type = with lib.types; coercedTo str (x: [ x ]) (listOf str);
    };

    validateURL = lib.mkOption {
      default = null;

      description = ''
        Access token validation endpoint.

        You only need to set this if you are using a self-hosted provider (e.g.
        Github Enterprise). If you're using a publicly hosted provider
        (e.g github.com), then the default works.
      '';

      example = "https://provider.example.com/user/emails";
      type = lib.types.nullOr lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.clientID != null || cfg.keyFile != null;
        message = "Either services.oauth2-proxy.clientID or services.oauth2-proxy.keyFile must be specified.";
      }
    ];

    systemd.services.oauth2-proxy =
      let
        needsKeycloak =
          lib.elem cfg.provider [
            "keycloak"
            "keycloak-oidc"
          ]
          && config.services.keycloak.enable;
      in
      {
        after = [ "network-online.target" ] ++ lib.optionals needsKeycloak [ "keycloak.service" ];
        description = "OAuth2 Proxy";
        path = [ cfg.package ];
        restartTriggers = [ cfg.keyFile ];

        serviceConfig = {
          EnvironmentFile = lib.mkIf (cfg.keyFile != null) cfg.keyFile;
          ExecStart = "${lib.getExe cfg.package} ${configString}";

          LoadCredential =
            lib.optional (cfg.clientSecretFile != null) "client-secret:${cfg.clientSecretFile}"
            ++ lib.optional (cfg.cookie.secretFile != null) "cookie-secret:${cfg.cookie.secretFile}";

          Restart = "always";
          User = "oauth2-proxy";
        };

        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ] ++ lib.optionals needsKeycloak [ "keycloak.service" ];
      };

    users.groups.oauth2-proxy = { };

    users.users.oauth2-proxy = {
      description = "OAuth2 Proxy";
      group = "oauth2-proxy";
      isSystemUser = true;
    };

    warnings = lib.mkIf (cfg.reverseProxy && cfg.trustedProxyIP == [ ]) [
      ''
        When config.services.oauth2-proxy.reverseProxy is enabled, configure config.services.oauth2-proxy.trustedProxyIP to the IPs or CIDR range(s) of the reverse proxies that are allowed to send X-Forwarded-* headers.
        If you leave it unset, OAuth2 Proxy currently trusts all source IPs for backwards compatibility, which means a client that can reach OAuth2 Proxy directly may be able to spoof forwarded headers.
      ''
    ];
  };
}
