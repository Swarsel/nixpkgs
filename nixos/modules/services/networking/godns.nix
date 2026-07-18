{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    types
    ;

  cfg = config.services.godns;

  settingsFormat = pkgs.formats.yaml { };
in
{
  options.services.godns = {
    enable = mkEnableOption "GoDNS service";
    package = mkPackageOption pkgs "godns" { };

    loadCredential = lib.mkOption {
      default = [ ];

      description = ''
        This can be used to pass secrets to the systemd service without adding
        them to the nix store.
      '';

      example = [ "login_token:/path/to/login_token" ];
      type = types.listOf types.str;
    };

    settings = mkOption {
      description = ''
        Configuration for GoDNS. Refer to the [configuration section](1) in the
        GoDNS GitHub repository for details.

        [1]: https://github.com/TimothyYe/godns?tab=readme-ov-file#configuration
      '';

      example = {
        domains = [
          {
            domain_name = "example.com";
            sub_domains = [ "foo" ];
          }
        ];

        interval = 300;
        ip_type = "IPv6";

        ipv6_urls = [
          "https://api6.ipify.org"
          "https://ip2location.io/ip"
          "https://v6.ipinfo.io/ip"
        ];

        login_token_file = "$CREDENTIALS_DIRECTORY/login_token";
        provider = "Cloudflare";
      };

      type = types.submodule {
        freeformType = settingsFormat.type;
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.godns = {
      after = [ "network.target" ];
      description = "GoDNS service";

      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${lib.getExe cfg.package} -c ${settingsFormat.generate "config.yaml" cfg.settings}";
        LoadCredential = cfg.loadCredential;
        Restart = "always";
        RestartSec = "2s";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = [ lib.maintainers.michaelvanstraten ];
}
