{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkOption
    types
    mkIf
    mkEnableOption
    mkPackageOption
    getExe
    optionalString
    ;

  cfg = config.services.shoko;

  shokoPlugins = pkgs.linkFarm "shoko-plugins" (
    map (pkg: {
      inherit (pkg) name;
      path = "${pkg}/lib/${pkg.pname}";
    }) cfg.plugins
  );
in
{
  options = {
    services.shoko = {
      enable = mkEnableOption "Shoko";
      package = mkPackageOption pkgs "shoko" { };

      openFirewall = mkOption {
        default = false;

        description = ''
          Open ports in the firewall for the ShokoAnime api and web interface.
        '';

        type = types.bool;
      };

      plugins = mkOption {
        default = [ ];

        description = ''
          The plugins to install.

          Note that if there are plugins installed imperatively when this
          option is used, they will be deleted.
        '';

        type = types.listOf types.package;
      };

      webui = mkPackageOption pkgs "shoko-webui" { nullable = true; };
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ 8111 ];

    systemd.services.shoko = {
      after = [ "network.target" ];
      description = "Shoko Server";
      # Not that it should be done, but this makes it easier to override the
      # StateDirectory option, if the user really wants to.
      environment.SHOKO_HOME = "/var/lib/${config.systemd.services.shoko.serviceConfig.StateDirectory}";

      # The rm calls are here, because it's pretty easy to get into a situation
      # where those directories are created imperatively, in which case the ln
      # calls (along with the service) would just fail.
      preStart =
        optionalString (cfg.webui != null) ''
          rm -rf "$STATE_DIRECTORY/webui"
          ln -s '${cfg.webui}' "$STATE_DIRECTORY/webui"
        ''
        + optionalString (cfg.plugins != [ ]) ''
          rm -rf "$STATE_DIRECTORY/plugins"
          ln -s '${shokoPlugins}' "$STATE_DIRECTORY/plugins"
        '';

      serviceConfig = {
        DynamicUser = true;
        ExecStart = getExe cfg.package;
        Restart = "on-failure";
        StateDirectory = "shoko";
        StateDirectoryMode = 750;
        Type = "simple";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ nanoyaki ];
}
