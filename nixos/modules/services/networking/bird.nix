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
    optionalString
    types
    ;

  cfg = config.services.bird;
  caps = [
    "CAP_NET_ADMIN"
    "CAP_NET_BIND_SERVICE"
    "CAP_NET_RAW"
  ];
in
{
  imports = [
    (lib.mkRemovedOptionModule [ "services" "bird2" ]
      "Use services.bird instead. bird3 is the new default bird package. You can choose to remain with bird2 by setting the service.bird.package option."
    )
    (lib.mkRemovedOptionModule [ "services" "bird6" ] "Use services.bird instead")
  ];

  ###### interface
  options = {
    services.bird = {
      config = mkOption {
        description = ''
          BIRD Internet Routing Daemon configuration file.
          <http://bird.network.cz/>
        '';

        type = types.lines;
      };

      enable = mkEnableOption "BIRD Internet Routing Daemon";
      package = lib.mkPackageOption pkgs "bird3" { };

      autoReload = mkOption {
        default = true;

        description = ''
          Whether bird should be automatically reloaded when the configuration changes.
        '';

        type = types.bool;
      };

      checkConfig = mkOption {
        default = true;

        description = ''
          Whether the config should be checked at build time.
          When the config can't be checked during build time, for example when it includes
          other files, either disable this option or use `preCheckConfig` to create
          the included files before checking.
        '';

        type = types.bool;
      };

      preCheckConfig = mkOption {
        default = "";

        description = ''
          Commands to execute before the config file check. The file to be checked will be
          available as {file}`bird.conf` in the current directory.

          Files created with this option will not be available at service runtime, only during
          build time checking.
        '';

        example = ''
          echo "cost 100;" > include.conf
        '';

        type = types.lines;
      };
    };
  };

  ###### implementation
  config = mkIf cfg.enable {
    environment.etc."bird/bird.conf".source = pkgs.writeTextFile {
      checkPhase = optionalString cfg.checkConfig ''
        ln -s $out bird.conf
        ${cfg.preCheckConfig}
        bird -d -p -c bird.conf || { exit=$?; cat -n bird.conf; exit $exit; }
      '';

      derivationArgs.nativeBuildInputs = lib.optional cfg.checkConfig cfg.package;
      name = "bird";
      text = cfg.config;
    };

    environment.systemPackages = [ cfg.package ];

    systemd.services.bird = {
      after = [ "network.target" ];
      description = "BIRD Internet Routing Daemon";
      reloadTriggers = lib.optional cfg.autoReload config.environment.etc."bird/bird.conf".source;

      serviceConfig = {
        AmbientCapabilities = caps;
        CapabilityBoundingSet = caps;
        ExecReload = "${lib.getExe' cfg.package "birdc"} configure";
        ExecStart = "${lib.getExe' cfg.package "bird"} -c /etc/bird/bird.conf";
        ExecStop = "${lib.getExe' cfg.package "birdc"} down";
        Group = "bird";
        MemoryDenyWriteExecute = "yes";
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectControlGroups = true;
        ProtectHome = "yes";
        ProtectKernelTunables = true;
        ProtectSystem = "full";
        Restart = "on-failure";
        RuntimeDirectory = "bird";
        SystemCallFilter = "~@cpu-emulation @debug @keyring @module @mount @obsolete @raw-io";
        Type = "forking";
        User = "bird";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users = {
      groups.bird = { };

      users.bird = {
        description = "BIRD Internet Routing Daemon user";
        group = "bird";
        isSystemUser = true;
      };
    };
  };

  meta = {
    maintainers = with lib.maintainers; [ herbetom ];
  };
}
