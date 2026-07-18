{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.cfdyndns;
in
{
  imports = [
    (lib.mkRemovedOptionModule [
      "services"
      "cfdyndns"
      "apikey"
    ] "Use services.cfdyndns.apikeyFile instead.")
  ];

  options = {
    services.cfdyndns = {
      enable = lib.mkEnableOption "Cloudflare Dynamic DNS Client";

      apiTokenFile = lib.mkOption {
        default = null;

        description = ''
          The path to a file containing the API Token
          used to authenticate with CloudFlare.
        '';

        type = lib.types.nullOr lib.types.str;
      };

      apikeyFile = lib.mkOption {
        default = null;

        description = ''
          The path to a file containing the API Key
          used to authenticate with CloudFlare.
        '';

        type = lib.types.nullOr lib.types.str;
      };

      email = lib.mkOption {
        description = ''
          The email address to use to authenticate to CloudFlare.
        '';

        type = lib.types.str;
      };

      records = lib.mkOption {
        default = [ ];

        description = ''
          The records to update in CloudFlare.
        '';

        example = [ "host.tld" ];
        type = lib.types.listOf lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.cfdyndns = {
      after = [ "network.target" ];
      description = "CloudFlare Dynamic DNS Client";

      environment = {
        CLOUDFLARE_RECORDS = "${lib.concatStringsSep "," cfg.records}";
      };

      script = ''
        ${lib.optionalString (cfg.apikeyFile != null) ''
          export CLOUDFLARE_APIKEY="$(cat ${lib.escapeShellArg cfg.apikeyFile})"
          export CLOUDFLARE_EMAIL="${cfg.email}"
        ''}
        ${lib.optionalString (cfg.apiTokenFile != null) ''
          export CLOUDFLARE_APITOKEN=$(${pkgs.systemd}/bin/systemd-creds cat CLOUDFLARE_APITOKEN_FILE)
        ''}
        ${pkgs.cfdyndns}/bin/cfdyndns
      '';

      serviceConfig = {
        DynamicUser = true;

        LoadCredential = lib.optional (
          cfg.apiTokenFile != null
        ) "CLOUDFLARE_APITOKEN_FILE:${cfg.apiTokenFile}";

        Type = "simple";
      };

      startAt = "*:0/5";
      wantedBy = [ "multi-user.target" ];
    };
  };
}
