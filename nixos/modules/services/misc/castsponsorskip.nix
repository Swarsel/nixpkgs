{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.castsponsorskip;
in
{
  options = {
    services.castsponsorskip = {
      config = lib.mkOption {
        default = { };
        description = "Configuration for the service. List of options all options <https://github.com/gabe565/CastSponsorSkip/blob/main/docs/envs.md>.";

        example = {
          CSS_SKIP_SPONSORS = false;
        };

        type = (pkgs.formats.yaml { }).type;
      };

      enable = lib.mkEnableOption "castsponsorskip";
      package = lib.mkPackageOption pkgs "castsponsorskip" { };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.castsponsorskip =
      let
        # Needed, even if empty, to avoid searching for a file in
        # the user home directory, which doesn't exist for
        # dynamic users
        config = (pkgs.formats.yaml cfg.config).generate "config.yaml" { };
      in
      {
        after = [ "network.target" ];
        description = "Skip YouTube ads and sponsorships on all local Google Cast devices";

        serviceConfig = {
          DynamicUser = true;
          ExecStart = "${lib.getExe cfg.package} --config=${config}";
          Restart = "always";
          TimeoutStopSec = "20s";
        };

        wantedBy = [ "multi-user.target" ];
      };
  };

  meta = {
    maintainers = with lib.maintainers; [ wariuccio ];
  };
}
