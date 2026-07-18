{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

let
  inherit (lib)
    any
    attrByPath
    attrValues
    concatMap
    concatStrings
    converge
    elem
    escapeShellArg
    escapeShellArgs
    filter
    filterAttrsRecursive
    flatten
    getAttr
    hasAttrByPath
    isAttrs
    isDerivation
    isList
    isStorePath
    literalExpression
    mapAttrsToList
    mergeAttrsList
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    mkRemovedOptionModule
    mkRenamedOptionModule
    optionals
    optionalString
    recursiveUpdate
    singleton
    splitString
    substring
    types
    unique
    ;

  inherit (utils)
    escapeSystemdExecArgs
    ;

  cfg = config.services.home-assistant;
  format = pkgs.formats.yaml { };

  # Post-process YAML output to add support for YAML functions, like
  # secrets or includes, by naively unquoting strings with leading bangs
  # and at least one space-separated parameter.
  # https://www.home-assistant.io/docs/configuration/secrets/
  renderYAMLFile =
    fn: yaml:
    pkgs.runCommand fn
      {
        preferLocalBuilds = true;
      }
      ''
        cp ${format.generate fn yaml} $out
        sed -i -e "s/'\!\([a-z_]\+\) \(.*\)'/\!\1 \2/;s/^\!\!/\!/;" $out
      '';

  # Filter null values from the configuration, so that we can still advertise
  # optional options in the config attribute.
  filteredConfig = converge (filterAttrsRecursive (_: v: !elem v [ null ])) (
    recursiveUpdate (customLovelaceModulesResources // themesConfig) (cfg.config or { })
  );
  configFile = renderYAMLFile "configuration.yaml" filteredConfig;

  lovelaceConfigFile =
    if cfg.lovelaceConfig != null then
      renderYAMLFile "ui-lovelace.yaml" cfg.lovelaceConfig
    else
      cfg.lovelaceConfigFile;

  # Components advertised by the home-assistant package
  availableComponents = cfg.package.availableComponents;

  # Components that were added by overriding the package
  explicitComponents = cfg.package.extraComponents;
  useExplicitComponent = component: elem component explicitComponents;

  # Given a component "platform", looks up whether it is used in the config
  # as `platform = "platform";`.
  #
  # For example, the component mqtt.sensor is used as follows:
  # config.sensor = [ {
  #   platform = "mqtt";
  #   ...
  # } ];
  usedPlatforms =
    config:
    # don't recurse into derivations possibly creating an infinite recursion
    if isDerivation config then
      [ ]
    else if isAttrs config then
      optionals (config ? platform) [ config.platform ] ++ concatMap usedPlatforms (attrValues config)
    else if isList config then
      concatMap usedPlatforms config
    else
      [ ];

  useComponentPlatform = component: elem component (usedPlatforms cfg.config);

  # Returns whether component is used in config, explicitly passed into package or
  # configured in the module.
  useComponent =
    component:
    hasAttrByPath (splitString "." component) cfg.config
    || useComponentPlatform component
    || useExplicitComponent component
    || builtins.elem component (
      cfg.extraComponents ++ cfg.defaultIntegrations ++ map (getAttr "domain") cfg.customComponents
    );

  # Final list of components passed into the package to include required dependencies
  extraComponents = filter useComponent availableComponents;

  package = (
    cfg.package.override (oldArgs: {
      # Respect overrides that already exist in the passed package and
      # concat it with values passed via the module.
      extraComponents = oldArgs.extraComponents or [ ] ++ extraComponents;

      extraPackages =
        ps:
        (oldArgs.extraPackages or (_: [ ]) ps)
        ++ (cfg.extraPackages ps)
        ++ (concatMap (component: component.propagatedBuildInputs or [ ]) cfg.customComponents);
    })
  );

  # Create a directory that holds all lovelace modules
  customLovelaceModulesDir = pkgs.buildEnv {
    name = "home-assistant-custom-lovelace-modules";
    paths = cfg.customLovelaceModules;
  };

  # Create parts of the lovelace config that reference lovelace modules as resources
  customLovelaceModulesResources = {
    lovelace.resources = map (card: {
      type = "module";
      url = "/local/nixos-lovelace-modules/${card.entrypoint or (card.pname + ".js")}?${card.version}";
    }) cfg.customLovelaceModules;
  };

  # Create a directory that holds all lovelace themes
  themesDir = pkgs.buildEnv {
    name = "home-assistant-themes";
    paths = cfg.themes;
  };

  # Auto-inject frontend.themes include directive when themes are used.
  themesConfig =
    if cfg.themes != [ ] then
      {
        frontend.themes = "!include_dir_merge_named ${themesDir}/themes";
      }
    else
      { };

  componentsUsingBluetooth = [
    # Components that require the AF_BLUETOOTH address family
    "august"
    "august_ble"
    "airthings_ble"
    "aranet"
    "bluemaestro"
    "bluetooth"
    "bluetooth_adapters"
    "bluetooth_le_tracker"
    "bluetooth_tracker"
    "bthome"
    "default_config"
    "eufylife_ble"
    "esphome"
    "fjaraskupan"
    "gardena_bluetooth"
    "govee_ble"
    "homekit_controller"
    "inkbird"
    "improv_ble"
    "keymitt_ble"
    "ld2410_ble"
    "leaone"
    "led_ble"
    "medcom_ble"
    "melnor"
    "moat"
    "mopeka"
    "motionblinds_ble"
    "oralb"
    "private_ble_device"
    "qingping"
    "rapt_ble"
    "ruuvi_gateway"
    "ruuvitag_ble"
    "sensirion_ble"
    "sensorpro"
    "sensorpush"
    "shelly"
    "snooz"
    "switchbot"
    "thermobeacon"
    "thermopro"
    "tilt_ble"
    "xiaomi_ble"
    "yalexs_ble"
  ];
  componentsUsingPacketCapture = [
    "default_config" # includes dhcp
    "dhcp"
  ];
  componentsUsingPing = [
    # Components that require the capset syscall for the ping wrapper
    "ping"
    "wake_on_lan"
  ];
  componentsUsingSerialDevices = [
    # Components that require access to serial devices (/dev/tty*)
    # List generated from home-assistant documentation:
    #   git clone https://github.com/home-assistant/home-assistant.io/
    #   cd source/_integrations
    #   rg "/dev/tty" -l | cut -d'/' -f3 | cut -d'.' -f1 | sort
    # And then extended by references found in the source code, these
    # mostly the ones using config flows already.
    "acer_projector"
    "alarmdecoder"
    "aurora_abb_powerone"
    "blackbird"
    "bryant_evolution"
    "crownstone"
    "deconz"
    "dsmr"
    "edl21"
    "elkm1"
    "elv"
    "enocean"
    "homeassistant_hardware"
    "homeassistant_yellow"
    "firmata"
    "flexit"
    "gpsd"
    "insteon"
    "kwb"
    "lacrosse"
    "landisgyr_heat_meter"
    "modbus"
    "modem_callerid"
    "mysensors"
    "nad"
    "numato"
    "nut"
    "opentherm_gw"
    "otbr"
    "rainforst_raven"
    "rflink"
    "rfxtrx"
    "scsgate"
    "serial"
    "serial_pm"
    "sms"
    "upb"
    "usb"
    "velbus"
    "w800rf32"
    "zha"
    "zwave"
    "zwave_js"

    # Custom components, maintained manually.
    "amshan"
    "benqprojector"
  ];
  componentsUsingInputDevices = [
    # Components that require access to input devices (/dev/input/*)
    "keyboard_remote"
  ];
in
{
  imports = [
    # Migrations in NixOS 22.05
    (mkRemovedOptionModule [
      "services"
      "home-assistant"
      "applyDefaultConfig"
    ] "The default config was migrated into services.home-assistant.config")
    (mkRemovedOptionModule [
      "services"
      "home-assistant"
      "autoExtraComponents"
    ] "Components are now parsed from services.home-assistant.config unconditionally")
    (mkRenamedOptionModule
      [ "services" "home-assistant" "port" ]
      [ "services" "home-assistant" "config" "http" "server_port" ]
    )
  ];

  options.services.home-assistant = {
    config = mkOption {
      description = ''
        Your {file}`configuration.yaml` as a Nix attribute set.

        YAML functions like [secrets](https://www.home-assistant.io/docs/configuration/secrets/)
        can be passed as a string and will be unquoted automatically.

        Unless this option is explicitly set to `null`
        we assume your {file}`configuration.yaml` is
        managed through this module and thereby overwritten on startup.
      '';

      example = literalExpression ''
        {
          homeassistant = {
            name = "Home";
            latitude = "!secret latitude";
            longitude = "!secret longitude";
            elevation = "!secret elevation";
            unit_system = "metric";
            time_zone = "UTC";
          };
          frontend = {
            themes = "!include_dir_merge_named themes";
          };
          http = {};
          feedreader.urls = [ "https://nixos.org/blogs.xml" ];
        }
      '';

      type = types.nullOr (
        types.submodule {
          options = {
            # This is a partial selection of the most common options, so new users can quickly
            # pick up how to match home-assistants config structure to ours. It also lets us preset
            # config values intelligently.

            homeassistant = {
              latitude = mkOption {
                default = null;

                description = ''
                  Latitude of your location required to calculate the time the sun rises and sets.
                '';

                example = 52.3;
                type = types.nullOr (types.either types.float types.str);
              };

              longitude = mkOption {
                default = null;

                description = ''
                  Longitude of your location required to calculate the time the sun rises and sets.
                '';

                example = 4.9;
                type = types.nullOr (types.either types.float types.str);
              };

              # https://www.home-assistant.io/docs/configuration/basic/
              name = mkOption {
                default = null;

                description = ''
                  Name of the location where Home Assistant is running.
                '';

                example = "Home";
                type = types.nullOr types.str;
              };

              temperature_unit = mkOption {
                default = null;

                description = ''
                  Override temperature unit set by unit_system. `C` for Celsius, `F` for Fahrenheit.
                '';

                example = "C";

                type = types.nullOr (
                  types.enum [
                    "C"
                    "F"
                  ]
                );
              };

              time_zone = mkOption {
                default = config.time.timeZone or null;

                defaultText = literalExpression ''
                  config.time.timeZone or null
                '';

                description = ''
                  Pick your time zone from the column TZ of Wikipedia’s [list of tz database time zones](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones).
                '';

                example = "Europe/Amsterdam";
                type = types.nullOr types.str;
              };

              unit_system = mkOption {
                default = null;

                description = ''
                  The unit system to use. This also sets temperature_unit, Celsius for Metric and Fahrenheit for US Customary.
                '';

                example = "metric";

                type = types.nullOr (
                  types.enum [
                    "metric"
                    "us_customary"
                  ]
                );
              };
            };

            http = {
              # https://www.home-assistant.io/integrations/http/
              server_host = mkOption {
                default = [
                  "0.0.0.0"
                  "::"
                ];

                description = ''
                  Only listen to incoming requests on specific IP/host. The default listed assumes support for IPv4 and IPv6.
                '';

                example = "::1";
                type = types.either types.str (types.listOf types.str);
              };

              server_port = mkOption {
                default = 8123;

                description = ''
                  The port on which to listen.
                '';

                type = types.port;
              };
            };

            lovelace = {
              # https://www.home-assistant.io/lovelace/dashboards/
              dashboards.nixos-lovelace = mkOption {
                default =
                  if cfg.lovelaceConfig != null || cfg.lovelaceConfigFile != null then
                    {
                      filename = "ui-lovelace.yaml";
                      icon = "mdi:view-dashboard";
                      mode = "yaml";
                      show_in_sidebar = true;
                      title = "Overview";
                    }
                  else
                    null;

                defaultText = literalExpression ''
                  if cfg.lovelaceConfig != null || cfg.lovelaceConfigFile != null then {
                    mode = "yaml";
                    filename = "ui-lovelace.yaml";
                    title = "Overview";
                    icon = "mdi:view-dashboard";
                    show_in_sidebar = true;
                  } else null
                '';

                description = ''
                  Default NixOS-managed Lovelace dashboard. Automatically populated
                  when {option}`lovelaceConfig` or {option}`lovelaceConfigFile` is set.

                  Additional dashboards can be defined under
                  `config.lovelace.dashboards.<name>`.

                  See <https://www.home-assistant.io/lovelace/dashboards/> for details.
                '';

                type = types.nullOr format.type;
              };

              resource_mode = mkOption {
                default = if cfg.customLovelaceModules != [ ] then "yaml" else null;

                defaultText = literalExpression ''
                  if cfg.customLovelaceModules != [ ] then "yaml" else null
                '';

                description = ''
                  Set to `"yaml"` to load Lovelace resources from YAML configuration,
                  or `"storage"` to manage them through the UI. See
                  <https://www.home-assistant.io/dashboards/dashboards/#resource_mode>.

                  Automatically set to `"yaml"` when {option}`customLovelaceModules`
                  is non-empty.
                '';

                type = types.nullOr (
                  types.enum [
                    "yaml"
                    "storage"
                  ]
                );
              };
            };
          };

          freeformType = format.type;
        }
      );
    };

    # Running home-assistant on NixOS is considered an installation method that is unsupported by the upstream project.
    # https://github.com/home-assistant/architecture/blob/master/adr/0012-define-supported-installation-method.md#decision
    enable = mkEnableOption "Home Assistant. Please note that this installation method is unsupported upstream";

    package = mkOption {
      default = pkgs.home-assistant.overrideAttrs (oldAttrs: {
        doInstallCheck = false;
      });

      defaultText = literalExpression ''
        pkgs.home-assistant.overrideAttrs (oldAttrs: {
          doInstallCheck = false;
        })
      '';

      description = ''
        The Home Assistant package to use.
      '';

      example = literalExpression ''
        pkgs.home-assistant.override {
          extraPackages = python3Packages: with python3Packages; [
            psycopg2
          ];
          extraComponents = [
            "default_config"
            "esphome"
            "met"
          ];
        }
      '';

      type = types.package;
    };

    blueprints = mergeAttrsList (
      map
        (domain: {
          ${domain} = mkOption {
            default = [ ];

            description = ''
              List of ${domain}
              [blueprints](https://www.home-assistant.io/docs/blueprint/) to
              install into {file}`''${config.services.home-assistant.configDir}/blueprints/${domain}`.
            '';

            example =
              if domain == "automation" then
                literalExpression ''
                  [
                    (pkgs.fetchurl {
                      url = "https://github.com/home-assistant/core/raw/2025.1.4/homeassistant/components/automation/blueprints/motion_light.yaml";
                      hash = "sha256-4HrDX65ycBMfEY2nZ7A25/d3ZnIHdpHZ+80Cblp+P5w=";
                    })
                  ]
                ''
              else if domain == "template" then
                literalExpression "[ \"\${pkgs.home-assistant.src}/homeassistant/components/template/blueprints/inverted_binary_sensor.yaml\" ]"
              else
                literalExpression "[ ./blueprint.yaml ]";

            type = types.listOf (types.coercedTo types.path (x: "${x}") types.pathInStore);
          };
        })
        # https://www.home-assistant.io/docs/blueprint/schema/#domain
        [
          "automation"
          "script"
          "template"
        ]
    );

    configDir = mkOption {
      default = "/var/lib/hass";
      description = "The config directory, where your {file}`configuration.yaml` is located.";
      type = types.path;
    };

    configWritable = mkOption {
      default = false;

      description = ''
        Whether to make {file}`configuration.yaml` writable.

        This will allow you to edit it from Home Assistant's web interface.

        This only has an effect if {option}`config` is set.
        However, bear in mind that it will be overwritten at every start of the service.
      '';

      type = types.bool;
    };

    customComponents = mkOption {
      default = [ ];

      description = ''
        List of custom component packages to install.

        Available components can be found below `pkgs.home-assistant-custom-components`.
      '';

      example = literalExpression ''
        with pkgs.home-assistant-custom-components; [
          prometheus_sensor
        ];
      '';

      type = types.listOf (
        types.addCheck types.package (p: p.isHomeAssistantComponent or false)
        // {
          description = "package that is a Home Assistant component";
          name = "home-assistant-component";
        }
      );
    };

    customLovelaceModules = mkOption {
      default = [ ];

      description = ''
        List of custom lovelace card packages to load as lovelace resources.

        Available cards can be found below `pkgs.home-assistant-custom-lovelace-modules`.

        ::: {.note}
        When non-empty, `lovelace.resource_mode` is automatically set to `"yaml"`
        so that resources are loaded from the YAML configuration.
        :::
      '';

      example = literalExpression ''
        with pkgs.home-assistant-custom-lovelace-modules; [
          mini-graph-card
          mini-media-player
        ];
      '';

      type = types.listOf types.package;
    };

    defaultIntegrations = mkOption {
      # https://github.com/home-assistant/core/blob/dev/homeassistant/bootstrap.py#L109
      default = [
        "application_credentials"
        "frontend"
        "hardware"
        "logger"
        "network"
        "system_health"

        # key features
        "automation"
        "person"
        "scene"
        "script"
        "tag"
        "zone"

        # built-in helpers
        "counter"
        "input_boolean"
        "input_button"
        "input_datetime"
        "input_number"
        "input_select"
        "input_text"
        "schedule"
        "timer"

        # non-supervisor
        "backup"
      ];

      description = ''
        List of integrations set are always set up, unless in recovery mode.
      '';

      readOnly = true;
      type = types.listOf (types.enum availableComponents);
    };

    extraArgs = mkOption {
      default = [ ];

      description = ''
        Extra arguments to pass to the hass executable.
      '';

      example = [ "--debug" ];
      type = types.listOf types.str;
    };

    extraComponents = mkOption {
      default = [
        # List of components required to complete the onboarding
        "default_config"
        "met"
        "esphome"
      ]
      ++ optionals pkgs.stdenv.hostPlatform.isAarch [
        # Use the platform as an indicator that we might be running on a RaspberryPi and include
        # relevant components
        "rpi_power"
      ];

      description = ''
        List of [components](https://www.home-assistant.io/integrations/) that have their dependencies included in the package.

        The component name can be found in the URL, for example `https://www.home-assistant.io/integrations/ffmpeg/` would map to `ffmpeg`.
      '';

      example = literalExpression ''
        [
          "analytics"
          "default_config"
          "esphome"
          "my"
          "shopping_list"
          "wled"
        ]
      '';

      type = types.listOf (types.enum availableComponents);
    };

    extraPackages = mkOption {
      default = _: [ ];

      defaultText = literalExpression ''
        python3Packages: with python3Packages; [];
      '';

      description = ''
        List of packages to add to propagatedBuildInputs.

        A popular example is `python3Packages.psycopg2`
        for PostgreSQL support in the recorder component.
      '';

      example = literalExpression ''
        python3Packages: with python3Packages; [
          # postgresql support
          psycopg2
        ];
      '';

      type = types.functionTo (types.listOf types.package);
    };

    finalPackage = mkOption {
      default = package;

      description = ''
        The final Home Assistant package which is being used in the service.
      '';

      internal = true;
      readOnly = true;
      type = types.package;
    };

    lovelaceConfig = mkOption {
      default = null;

      description = ''
        Your {file}`ui-lovelace.yaml` as a Nix attribute set.
        Setting this option will automatically configure a Lovelace dashboard in YAML mode.

        Beware that setting this option will delete your previous {file}`ui-lovelace.yaml`
      '';

      # from https://www.home-assistant.io/lovelace/dashboards/
      example = literalExpression ''
        {
          title = "My Awesome Home";
          views = [ {
            title = "Example";
            cards = [ {
              type = "markdown";
              title = "Lovelace";
              content = "Welcome to your **Lovelace UI**.";
            } ];
          } ];
        }
      '';

      type = types.nullOr format.type;
    };

    lovelaceConfigFile = mkOption {
      default = null;

      description = ''
        Your {file}`ui-lovelace.yaml` managed as configuration file.
        Setting this option will automatically configure a Lovelace dashboard in YAML mode.
      '';

      example = "/path/to/ui-lovelace.yaml";
      type = types.nullOr types.path;
    };

    lovelaceConfigWritable = mkOption {
      default = false;

      description = ''
        Whether to make {file}`ui-lovelace.yaml` writable.

        This will allow you to edit it from Home Assistant's web interface.

        This only has an effect if {option}`lovelaceConfig` is set.
        However, bear in mind that it will be overwritten at every start of the service.
      '';

      type = types.bool;
    };

    openFirewall = mkOption {
      default = false;

      description = ''
        Whether to open the firewall for the specified frontend port

        :::{.note}
        For components specific ports see {option}`services.home-assistant.openFirewallForComponents`.
        :::
      '';

      type = types.bool;
    };

    openFirewallForComponents = mkOption {
      default = false;

      description = ''
        Whether to open required firewall ports for enabled components.

        :::{.note}
        For the frontend see {option}`services.home-assistant.openFirewall`.
        :::
      '';

      type = types.bool;
    };

    themes = mkOption {
      default = [ ];

      description = ''
        List of themes to load.

        Available themes can be found below `pkgs.home-assistant-themes`.

        ::: {.note}
        When `themes` is set, the module takes authoritative control
        over the `frontend.themes` setting in
        {option}`services.home-assistant.config`.
        :::
      '';

      example = literalExpression ''
        with pkgs.home-assistant-themes; [
          material-you-theme
        ];
      '';

      type = types.listOf (
        types.addCheck types.package (p: p.isHomeAssistantTheme or false)
        // {
          description = "package that is a Home Assistant theme";
          name = "home-assistant-theme";
        }
      );
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.openFirewall -> cfg.config != null;
        message = "openFirewall can only be used with a declarative config";
      }
      {
        assertion = !(cfg.lovelaceConfig != null && cfg.lovelaceConfigFile != null);
        message = "Only one of `lovelaceConfig` or `lovelaceConfigFile` can be configured at the same time.";
      }
      {
        assertion = cfg.themes != [ ] -> !(hasAttrByPath [ "frontend" "themes" ] (cfg.config or { }));
        message = "`services.home-assistant.themes` and `services.home-assistant.config.frontend.themes` cannot both be set. When `themes` is non-empty the module sets `frontend.themes` authoritatively.";
      }
    ];

    # symlink the configuration to /etc/home-assistant
    environment.etc = mkMerge [
      (mkIf (cfg.config != null && !cfg.configWritable) {
        "home-assistant/configuration.yaml".source = configFile;
      })

      (mkIf
        ((cfg.lovelaceConfig != null || cfg.lovelaceConfigFile != null) && !cfg.lovelaceConfigWritable)
        {
          "home-assistant/ui-lovelace.yaml".source = lovelaceConfigFile;
        }
      )
    ];

    networking.firewall.allowedTCPPorts = mkMerge [
      (mkIf cfg.openFirewall [ cfg.config.http.server_port ])
      (mkIf cfg.openFirewallForComponents (
        # https://www.home-assistant.io/integrations/homekit/#firewall
        optionals (useComponent "homekit") [ 21063 ]
        # https://www.home-assistant.io/integrations/sonos/#network-requirements
        ++ optionals (useComponent "sonos") [ 1400 ]
      ))
    ];

    networking.firewall.allowedUDPPorts = mkIf cfg.openFirewallForComponents (
      # https://www.home-assistant.io/integrations/homekit/#firewall
      optionals (useComponent "homekit") [ 5353 ]
    );

    systemd.services.home-assistant = {
      after = [
        "network-online.target"

        # prevent races with database creation
        "mysql.service"
        "postgresql.target"
      ];

      description = "Home Assistant";
      environment.PYTHONPATH = package.pythonPath;

      path =
        with pkgs;
        lib.optionals (useComponent "go2rtc") [ pkgs.go2rtc ]
        ++ lib.optionals (useComponent "picotts") [ pkgs.picotts ]
        ++ lib.optionals (any useComponent componentsUsingPing) [ unixtools.ping ];

      preStart =
        let
          copyConfig =
            if cfg.configWritable then
              ''
                cp --no-preserve=mode ${configFile} "${cfg.configDir}/configuration.yaml"
              ''
            else
              ''
                rm -f "${cfg.configDir}/configuration.yaml"
                ln -s /etc/home-assistant/configuration.yaml "${cfg.configDir}/configuration.yaml"
              '';
          copyLovelaceConfig =
            if cfg.lovelaceConfigWritable then
              ''
                rm -f "${cfg.configDir}/ui-lovelace.yaml"
                cp --no-preserve=mode ${lovelaceConfigFile} "${cfg.configDir}/ui-lovelace.yaml"
              ''
            else
              ''
                ln -fs /etc/home-assistant/ui-lovelace.yaml "${cfg.configDir}/ui-lovelace.yaml"
              '';
          copyCustomLovelaceModules =
            if cfg.customLovelaceModules != [ ] then
              ''
                mkdir -p "${cfg.configDir}/www"
                ln -fns ${customLovelaceModulesDir} "${cfg.configDir}/www/nixos-lovelace-modules"
              ''
            else
              ''
                rm -f "${cfg.configDir}/www/nixos-lovelace-modules"
              '';
          copyCustomComponents = ''
            mkdir -p "${cfg.configDir}/custom_components"

            # remove components symlinked in from below the /nix/store
            readarray -d "" components < <(find "${cfg.configDir}/custom_components" -maxdepth 1 -type l -print0)
            for component in "''${components[@]}"; do
              if [[ "$(readlink "$component")" =~ ^${escapeShellArg builtins.storeDir} ]]; then
                rm "$component"
              fi
            done

            # recreate symlinks for desired components
            declare -a components=(${escapeShellArgs cfg.customComponents})
            for component in "''${components[@]}"; do
              readarray -t manifests < <(find "$component" -name manifest.json)
              readarray -t paths < <(dirname "''${manifests[@]}")
              ln -fns "''${paths[@]}" "${cfg.configDir}/custom_components/"
            done
          '';

          removeBlueprints = ''
            # remove blueprints symlinked in from below the /nix/store
            readarray -d "" blueprints < <(find "${cfg.configDir}/blueprints" -maxdepth 2 -type l -print0)
            for blueprint in "''${blueprints[@]}"; do
              if [[ "$(readlink "$blueprint")" =~ ^${escapeShellArg builtins.storeDir} ]]; then
                rm "$blueprint"
              fi
            done
          '';
          copyBlueprint =
            domain: blueprint:
            let
              filename =
                if isStorePath blueprint then substring 33 (-1) (baseNameOf blueprint) else baseNameOf blueprint;
              path = "${cfg.configDir}/blueprints/${domain}";
            in
            ''
              mkdir -p ${escapeShellArg path}
              ln -s ${escapeShellArg blueprint} ${escapeShellArg "${path}/${filename}"}
            '';
          copyBlueprints = concatStrings (
            flatten (mapAttrsToList (domain: map (copyBlueprint domain)) cfg.blueprints)
          );
        in
        (optionalString (cfg.config != null) copyConfig)
        + (optionalString (cfg.lovelaceConfig != null) copyLovelaceConfig)
        + copyCustomLovelaceModules
        + copyCustomComponents
        + removeBlueprints
        + copyBlueprints;

      reloadTriggers =
        optionals (cfg.config != null) [ configFile ]
        ++ optionals (cfg.lovelaceConfig != null || cfg.lovelaceConfigFile != null) [ lovelaceConfigFile ];

      serviceConfig =
        let
          # List of capabilities to equip home-assistant with, depending on configured components
          capabilities = unique (
            [
              # Empty string first, so we will never accidentally have an empty capability bounding set
              # https://github.com/NixOS/nixpkgs/issues/120617#issuecomment-830685115
              ""
            ]
            ++ optionals (any useComponent componentsUsingBluetooth) [
              # Required for interaction with hci devices and bluetooth sockets, identified by bluetooth-adapters dependency
              # https://www.home-assistant.io/integrations/bluetooth_le_tracker/#rootless-setup-on-core-installs
              "CAP_NET_ADMIN"
              "CAP_NET_RAW"
            ]
            ++ optionals (any useComponent componentsUsingPacketCapture) [
              # Raw packet capture using AF_PACKET
              "CAP_NET_RAW"
            ]
            ++ optionals (useComponent "emulated_hue") [
              # Alexa looks for the service on port 80
              # https://www.home-assistant.io/integrations/emulated_hue
              "CAP_NET_BIND_SERVICE"
            ]
            ++ optionals (useComponent "nmap_tracker") [
              # https://www.home-assistant.io/integrations/nmap_tracker#linux-capabilities
              "CAP_NET_ADMIN"
              "CAP_NET_BIND_SERVICE"
              "CAP_NET_RAW"
            ]
          );
        in
        {
          # Hardening
          AmbientCapabilities = capabilities;
          CapabilityBoundingSet = capabilities;

          DeviceAllow =
            optionals (any useComponent componentsUsingSerialDevices) [
              "char-ttyACM rw"
              "char-ttyAMA rw"
              "char-ttyUSB rw"
            ]
            ++ optionals (any useComponent componentsUsingInputDevices) [
              "char-input rw"
            ];

          DevicePolicy = "closed";

          ExecReload =
            (escapeSystemdExecArgs [
              (lib.getExe' pkgs.coreutils "kill")
              "-HUP"
            ])
            + " $MAINPID";

          ExecStart = escapeSystemdExecArgs (
            [
              (lib.getExe package)
              "--config"
              cfg.configDir
            ]
            ++ cfg.extraArgs
          );

          Group = "hass";
          KillSignal = "SIGINT";
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;
          PrivateTmp = true;
          PrivateUsers = false; # prevents gaining capabilities in the host namespace
          ProcSubset = "all";
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectProc = "invisible";
          ProtectSystem = "strict";

          ReadWritePaths =
            let
              # Allow rw access to explicitly configured paths
              cfgPath = [
                "config"
                "homeassistant"
                "allowlist_external_dirs"
              ];
              value = attrByPath cfgPath [ ] cfg;
              allowPaths = if isList value then value else singleton value;
            in
            [ "${cfg.configDir}" ] ++ allowPaths;

          RemoveIPC = true;
          Restart = "on-failure";
          # Signal handling
          # homeassistant/helpers/signal.py
          RestartForceExitStatus = "100";

          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
            "AF_NETLINK"
            "AF_UNIX"
          ]
          ++ optionals (any useComponent componentsUsingBluetooth) [
            "AF_BLUETOOTH"
          ]
          ++ optionals (any useComponent componentsUsingPacketCapture) [
            "AF_PACKET"
          ];

          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          SuccessExitStatus = "100";

          SupplementaryGroups =
            optionals (any useComponent componentsUsingSerialDevices) [
              "dialout"
            ]
            ++ optionals (any useComponent componentsUsingInputDevices) [
              "input"
            ];

          SystemCallArchitectures = "native";

          SystemCallFilter = [
            "@system-service"
            "~@privileged"
          ]
          ++ optionals (any useComponent componentsUsingPing) [
            "capset"
            "setuid"
          ];

          UMask = "0077";
          User = "hass";
          WorkingDirectory = cfg.configDir;
        };

      wants = [ "network-online.target" ];
    };

    systemd.targets.home-assistant = rec {
      after = wants;
      description = "Home Assistant";
      wantedBy = [ "multi-user.target" ];
      wants = [ "home-assistant.service" ];
    };

    users.groups.hass.gid = config.ids.gids.hass;

    users.users.hass = {
      createHome = true;
      group = "hass";
      home = cfg.configDir;
      uid = config.ids.uids.hass;
    };

    warnings = optionals (cfg.config ? lovelace.mode) [
      ''
        services.home-assistant.config.lovelace.mode is deprecated.
        Home Assistant 2026.8 renames the legacy top-level `lovelace.mode`
        setting in favour of per-dashboard configuration.

        Use `services.home-assistant.config.lovelace.dashboards` and
        `services.home-assistant.config.lovelace.resource_mode` instead.

        See https://www.home-assistant.io/dashboards/dashboards/ for details.
      ''
    ];
  };

  meta = {
    buildDocsInSandbox = false;
    teams = [ lib.teams.home-assistant ];
  };
}
