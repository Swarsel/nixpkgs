{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  inherit (lib.types)
    attrsOf
    coercedTo
    listOf
    oneOf
    str
    int
    bool
    ;
  cfg = config.services.smartdns;

  confFile = pkgs.writeText "smartdns.conf" (
    with generators;
    toKeyValue {
      listsAsDuplicateKeys = true; # Allowing duplications because we need to deal with multiple entries with the same key.

      mkKeyValue = mkKeyValueDefault {
        mkValueString = v: if isBool v then boolToYesNo v else mkValueStringDefault { } v;
      } " ";
    } cfg.settings
  );
in
{
  options.services.smartdns = {
    enable = mkEnableOption "SmartDNS DNS server";

    bindPort = mkOption {
      default = 53;
      description = "DNS listening port number.";
      type = types.port;
    };

    settings = mkOption {
      description = ''
        A set that will be generated into configuration file, see the [SmartDNS README](https://github.com/pymumu/smartdns/blob/master/ReadMe_en.md#configuration-parameter) for details of configuration parameters.
        You could override the options here like {option}`services.smartdns.bindPort` by writing `settings.bind = ":5353 -no-rule -group example";`.
      '';

      example = literalExpression ''
        {
          bind = ":5353 -no-rule -group example";
          cache-size = 4096;
          server-tls = [ "8.8.8.8:853" "1.1.1.1:853" ];
          server-https = "https://cloudflare-dns.com/dns-query -exclude-default-group";
          prefetch-domain = true;
          speed-check-mode = "ping,tcp:80";
        };
      '';

      type =
        let
          atom = oneOf [
            str
            int
            bool
          ];
        in
        attrsOf (coercedTo atom toList (listOf atom));
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."default/smartdns".source = "${pkgs.smartdns}/etc/default/smartdns";
    environment.etc."smartdns/smartdns.conf".source = confFile;
    services.smartdns.settings.bind = mkDefault ":${toString cfg.bindPort}";
    systemd.packages = [ pkgs.smartdns ];
    systemd.services.smartdns.restartTriggers = [ confFile ];
    systemd.services.smartdns.wantedBy = [ "multi-user.target" ];
  };
}
