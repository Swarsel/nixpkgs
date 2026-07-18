{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    mkEnableOption
    mkPackageOption
    mkOption
    literalExpression
    hasAttr
    toList
    length
    head
    tail
    concatStringsSep
    optionalString
    optionalAttrs
    isDerivation
    recursiveUpdate
    getExe
    types
    maintainers
    makeBinPath
    ;
  cfg = config.services.wivrn;
  configFormat = pkgs.formats.json { };

  # For the application option to work with systemd PATH, we find the store binary path of
  # the package, concat all of the following strings, and then update the application attribute.

  # Since the json config attribute type "configFormat.type" doesn't allow specifying types for
  # individual attributes, we have to type check manually.

  # The application option should be a list with package as the first element, though a single package is also valid.
  # Note that this module depends on the package containing the meta.mainProgram attribute.

  # Check if an application is provided
  applicationAttrExists = hasAttr "application" cfg.config.json;
  applicationList = toList cfg.config.json.application;
  applicationListNotEmpty = length applicationList != 0;
  applicationCheck = applicationAttrExists && applicationListNotEmpty;

  # Manage packages and their exe paths
  applicationAttr = head applicationList;
  applicationPackage = mkIf applicationCheck applicationAttr;
  applicationPackageExe = getExe applicationAttr;
  serverPackageExe = (
    if cfg.highPriority then "${config.security.wrapperDir}/wivrn-server" else getExe cfg.package
  );

  # Manage strings
  applicationStrings = tail applicationList;
  applicationConcat = concatStringsSep " " ([ applicationPackageExe ] ++ applicationStrings);

  # Manage config file
  applicationUpdate = recursiveUpdate cfg.config.json (
    optionalAttrs applicationCheck { application = applicationConcat; }
  );
  configFile = configFormat.generate "config.json" applicationUpdate;
  enabledConfig = optionalString cfg.config.enable "-f ${configFile}";

  # Manage server executables and flags
  serverCmdline = concatStringsSep " " (
    [
      serverPackageExe
      enabledConfig
    ]
    ++ cfg.extraServerFlags
  );
  serverExec =
    if cfg.steam.enable then
      lib.getExe (
        pkgs.writeShellScriptBin "start-wivrn-server" ''
          # The server needs Steam in PATH to open Steam games from the application launcher
          export PATH="${makeBinPath [ cfg.steam.package ]}:$PATH"
          exec -a wivrn-server ${serverCmdline}
        ''
      )
    else
      serverCmdline;
in
{
  imports = [
    (lib.mkRemovedOptionModule [ "services" "wivrn" "defaultRuntime" ] ''
      WiVRn now manages the active runtime itself, so this option has been removed.
    '')
  ];

  options = {
    services.wivrn = {
      config = {
        enable = mkEnableOption "configuration for WiVRn";

        json = mkOption {
          default = { };

          description = ''
            Configuration for WiVRn. The attributes are serialized to JSON in config.json. The server will fallback to default values for any missing attributes.

            Like upstream, the application option is a list including the application and it's flags. In the case of the NixOS module however, the first element of the list must be a package. The module will assert otherwise.
            The application can be set to a single package because it gets passed to lib.toList, though this will not allow for flags to be passed.

            WiVRn has good default configurations and most options can be configured at runtime so it is recommended to leave this empty and try the defaults before attempting manual configuration.

            See <https://github.com/WiVRn/WiVRn/blob/master/docs/configuration.md>
          '';

          example = literalExpression ''
            {
              # left eye, hardware; right eye, software; transparency, hardware
              encoder = [
                {
                  encoder = "vulkan";
                  codec = "h265";
                }
                {
                  encoder = "x264";
                  codec = "h264";
                }
                {
                  encoder = "vulkan";
                  codec = "h265";
                }
              ];
              application = [ pkgs.wayvr ];
            }
          '';

          type = configFormat.type;
        };
      };

      enable = mkEnableOption "WiVRn, an OpenXR streaming application";
      package = mkPackageOption pkgs "wivrn" { };
      autoStart = mkEnableOption "starting the service by default";

      extraServerFlags = mkOption {
        default = [ ];
        description = "Flags to add to the wivrn service.";
        example = literalExpression ''[ "--no-publish-service" ]'';
        type = types.listOf types.str;
      };

      highPriority = mkEnableOption "high priority capability for asynchronous reprojection";

      monadoEnvironment = mkOption {
        default = { };
        description = "Environment variables to be passed to the Monado environment.";
        type = types.attrs;
      };

      openFirewall = mkEnableOption "the default ports in the firewall for the WiVRn server";

      steam = {
        enable = lib.mkEnableOption "Steam support" // {
          default = true;
        };

        package = mkPackageOption pkgs "steam" { };

        importOXRRuntimes = mkEnableOption ''
          Sets `PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES` system-wide to allow Steam to automatically discover the WiVRn server.

          Note that you may have to logout for this variable to be visible
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !applicationCheck || isDerivation applicationAttr;
        message = "The application in WiVRn configuration is not a package. Please ensure that the application is a package or that a package is the first element in the list.";
      }
    ];

    environment = {
      pathsToLink = [ "/share/openxr" ];

      sessionVariables = mkIf cfg.steam.importOXRRuntimes {
        PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES = "1";
      };

      systemPackages = [
        cfg.package
        applicationPackage
      ];
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ 9757 ];
      allowedUDPPorts = [ 9757 ];
    };

    security.wrappers."wivrn-server" = mkIf cfg.highPriority {
      capabilities = "cap_sys_nice+eip";
      group = "root";
      owner = "root";
      setuid = false;
      source = getExe cfg.package;
    };

    services = {
      avahi = {
        enable = true;

        publish = {
          enable = true;
          userServices = true;
        };
      };
    };

    services.firewalld.packages = [ cfg.package ];

    systemd.user = {
      services = {
        wivrn = {
          description = "WiVRn XR runtime service";
          # WiVRn scans for .desktop files in $XDG_DATA_DIRS for the application launcher,
          # which will execute the command in Exec when selected in the headset. If the
          # Exec path isn't absolute, it will be resolved relative to $PATH, so we must
          # not override the value of $PATH.
          enableDefaultPath = false;

          environment = recursiveUpdate {
            IPC_EXIT_ON_DISCONNECT = "off";
            PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES = mkIf cfg.steam.importOXRRuntimes "1";
            # Default options
            # https://gitlab.freedesktop.org/monado/monado/-/blob/598080453545c6bf313829e5780ffb7dde9b79dc/src/xrt/targets/service/monado.in.service#L12
            XRT_COMPOSITOR_LOG = "debug";
            XRT_PRINT_OPTIONS = "on";
          } cfg.monadoEnvironment;

          restartTriggers = [
            cfg.package
          ]
          ++ lib.optionals cfg.steam.enable [ cfg.steam.package ];

          serviceConfig = (
            if cfg.highPriority then
              {
                ExecStart = serverExec;
              }
            # Hardening options break high-priority
            else
              {
                AmbientCapabilities = [ "CAP_SYS_NICE" ];
                # Hardening options
                CapabilityBoundingSet = [ "CAP_SYS_NICE" ];
                ExecStart = serverExec;
                LockPersonality = true;
                NoNewPrivileges = true;
                PrivateTmp = true;
                ProtectClock = true;
                ProtectControlGroups = true;
                ProtectKernelLogs = true;
                ProtectKernelModules = true;
                ProtectKernelTunables = true;
                ProtectProc = "invisible";
                ProtectSystem = "strict";
                RemoveIPC = true;
                RestrictNamespaces = true;
                RestrictSUIDSGID = true;
              }
          );

          unitConfig.ConditionUser = "!@system";
          wantedBy = mkIf cfg.autoStart [ "default.target" ];
        };
      };
    };
  };

  meta.maintainers = with maintainers; [ passivelemon ];
}
