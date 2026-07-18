{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.services.syncthing;
  opt = options.services.syncthing;
  defaultUser = "syncthing";
  defaultGroup = defaultUser;
  settingsFormat = pkgs.formats.json { };
  cleanedConfig = lib.converge (lib.filterAttrsRecursive (_: v: v != null && v != { })) cfg.settings;

  isUnixGui = lib.strings.hasPrefix "unix://" cfg.guiAddress;

  # Syncthing supports serving the GUI over Unix sockets. If that happens, the
  # API is served over the Unix socket as well.  This function returns the correct
  # curl arguments for the address portion of the curl command for both network
  # and Unix socket addresses.
  curlAddressArgs =
    path:
    if
      isUnixGui
    # if cfg.guiAddress is a unix socket, tell curl explicitly about it
    # note that the syncthing.local in front of `${path}` is the hostname, which is
    # required.
    then
      "--unix-socket ${lib.strings.removePrefix "unix://" cfg.guiAddress} http://syncthing.local${path}"
    # no adjustments are needed if cfg.guiAddress is a network address
    else
      "${cfg.guiAddress}${path}";

  devices = lib.mapAttrsToList (
    _: device:
    device
    // {
      deviceID = device.id;
    }
  ) cfg.settings.devices;

  anyAutoAccept = builtins.any (dev: dev.autoAcceptFolders) devices;

  folders = lib.pipe cfg.settings.folders [
    (lib.filterAttrs (_: folder: folder.enable))
    builtins.attrValues
    (map (
      folder:
      folder
      // {
        devices = map (
          device:
          if builtins.isString device then
            { deviceId = cfg.settings.devices.${device}.id; }
          else
            { deviceId = cfg.settings.devices.${device.name}.id; } // device
        ) folder.devices;
      }
    ))
  ];

  jq = "${pkgs.jq}/bin/jq";
  grep = lib.getExe pkgs.gnugrep;
  updateConfig = pkgs.writers.writeBash "merge-syncthing-config" (
    ''
      set -efu

      # be careful not to leak secrets in the filesystem or in process listings
      umask 0077

      curl() {
          # get the api key by parsing the config.xml
          while
              ! ${pkgs.libxml2}/bin/xmllint \
                  --xpath 'string(configuration/gui/apikey)' \
                  ${cfg.configDir}/config.xml \
                  >"$RUNTIME_DIRECTORY/api_key"
          do sleep 1; done
          (printf "X-API-Key: "; cat "$RUNTIME_DIRECTORY/api_key") >"$RUNTIME_DIRECTORY/headers"
          ${pkgs.curl}/bin/curl -sSLk -H "@$RUNTIME_DIRECTORY/headers" \
              --retry 1000 --retry-delay 1 --retry-all-errors \
              "$@"
      }

      # Before version 2.0.0, Syncthing used LevelDB. In version 2.0.0,
      # Syncthing started using SQLite. If you upgrade from an older version of
      # Syncthing that uses LevelDB to a newer version of Syncthing that uses
      # SQLite, then Syncthing will automatically do a one time database
      # migration [1]. While the migration is happening, the regular Syncthing
      # REST API is not available. Instead, a temporary API is made available
      # in its place.
      #
      # The rest of this script depends on Syncthing’s regular REST API. This
      # next part checks to see if Syncthing is currently providing the
      # temporary API. If it is, this next part will wait until the regular API
      # is available.
      #
      # [1]: <https://github.com/syncthing/syncthing/releases/tag/v2.0.0>
      while true
      do
        # We can use pretty much any API endpoint here. I chose to use
        # /rest/noauth/health because it doesn’t return a lot of data and
        # because doing a “health check” seems like an appropriate way to check
        # to see if the regular API is “alive” or not.
        content_type="$(curl \
          -o /dev/null \
          -w '%header{Content-Type}' \
          ${curlAddressArgs "/rest/noauth/health"}
        )"
        # The “($|([ \t]*;.*))” part at the end allows us to not worry about
        # whether or not the Content-Type contains any parameters. “$” matches
        # the end of the string which indicates that no parameters were used
        # [1][2]. The “[ \t]*;” part matches OWS [3] followed by a semicolon
        # which indicates that at least one parameter was used [4].
        #
        # We use “grep -i” here because media types are case-insensitive [2].
        #
        # [1]: <https://httpwg.org/specs/rfc9110.html#field.content-type>
        # [2]: <https://httpwg.org/specs/rfc9110.html#media.type>
        # [3]: <https://httpwg.org/specs/rfc9110.html#whitespace>
        # [4]: <https://httpwg.org/specs/rfc9110.html#parameter>
        if printf %s "$content_type" | ${lib.escapeShellArg grep} -qiP '^text/plain($|([ \t]*;.*))'
        then
          echo Waiting for Syncthing to finish its database migration…
          sleep 30
        # TODO: This next regex pattern can be simplified if this Syncthing bug gets fixed [1].
        #
        # [1]: <https://github.com/syncthing/syncthing/issues/10500>
        elif printf %s "$content_type" | ${lib.escapeShellArg grep} -qiP '^application/json($|([ \t]*;.*))'
        then
          echo 'Syncthing is not doing a database migration (anymore).'
          break
        else
          printf 'ERROR: Syncthing responded with an unexpected Content-Type: %s\n' "$content_type"
          # This is the EX_PROTOCOL exit status from <man:sysexits.h(3head)>.
          exit 76
        fi
      done
    ''
    +

      /*
        Syncthing's rest API for the folders and devices is almost identical.
        Hence we iterate them using lib.pipe and generate shell commands for both at
        the same time.
      */
      (lib.pipe
        {
          # The attributes below are the only ones that are different for devices /
          # folders.
          devs = {
            GET_IdAttrName = "deviceID";
            baseAddress = curlAddressArgs "/rest/config/devices";
            conf = devices;
            new_conf_IDs = map (v: v.id) devices;
            override = cfg.overrideDevices;
          };

          dirs = {
            GET_IdAttrName = "id";
            baseAddress = curlAddressArgs "/rest/config/folders";
            conf = folders;
            ignoreAddress = curlAddressArgs "/rest/db/ignores";
            new_conf_IDs = map (v: v.id) folders;
            override = cfg.overrideFolders;
          };
        }
        [
          # Now for each of these attributes, write the curl commands that are
          # identical to both folders and devices.
          (lib.mapAttrs (
            conf_type: s:
            # We iterate the `conf` list now, and run a curl -X POST command for each, that
            # should update that device/folder only.
            lib.pipe s.conf [
              # Quoting https://docs.syncthing.net/rest/config.html:
              #
              # > PUT takes an array and POST a single object. In both cases if a
              # given folder/device already exists, it’s replaced, otherwise a new
              # one is added.
              #
              # What's not documented, is that using PUT will remove objects that
              # don't exist in the array given. That's why we use here `POST`, and
              # only if s.override == true then we DELETE the relevant folders
              # afterwards.
              (map (
                new_cfg:
                let
                  jsonPreSecretsFile = pkgs.writeTextFile {
                    name = "${conf_type}-${new_cfg.id}-conf-pre-secrets.json";
                    # Remove the ignorePatterns attribute, it is handled separately
                    text = builtins.toJSON (removeAttrs new_cfg [ "ignorePatterns" ]);
                  };
                  injectSecretsJqCmd =
                    {
                      # There are no secrets in `devs`, so no massaging needed.
                      "devs" = "${jq} .";

                      "dirs" =
                        let
                          folder = new_cfg;
                          devicesWithSecrets = lib.pipe folder.devices [
                            (lib.filter (device: (builtins.isAttrs device) && device ? encryptionPasswordFile))
                            (map (device: {
                              deviceId = device.deviceId;
                              secretPath = device.encryptionPasswordFile;
                              variableName = "secret_${builtins.hashString "sha256" device.encryptionPasswordFile}";
                            }))
                          ];
                          # At this point, `jsonPreSecretsFile` looks something like this:
                          #
                          #   {
                          #     ...,
                          #     "devices": [
                          #       {
                          #         "deviceId": "id1",
                          #         "encryptionPasswordFile": "/etc/bar-encryption-password",
                          #         "name": "..."
                          #       }
                          #     ],
                          #   }
                          #
                          # We now generate a `jq` command that can replace those
                          # `encryptionPasswordFile`s with `encryptionPassword`.
                          # The `jq` command ends up looking like this:
                          #
                          #   jq --rawfile secret_DEADBEEF /etc/bar-encryption-password '
                          #     .devices[] |= (
                          #       if .deviceId == "id1" then
                          #         del(.encryptionPasswordFile) |
                          #         .encryptionPassword = $secret_DEADBEEF
                          #       else
                          #         .
                          #       end
                          #     )
                          #   '
                          jqUpdates = map (device: ''
                            .devices[] |= (
                              if .deviceId == "${device.deviceId}" then
                                del(.encryptionPasswordFile) |
                                .encryptionPassword = ''$${device.variableName}
                              else
                                .
                              end
                            )
                          '') devicesWithSecrets;
                          jqRawFiles = map (
                            device: "--rawfile ${device.variableName} ${lib.escapeShellArg device.secretPath}"
                          ) devicesWithSecrets;
                        in
                        "${jq} ${lib.concatStringsSep " " jqRawFiles} ${
                          lib.escapeShellArg (lib.concatStringsSep "|" ([ "." ] ++ jqUpdates))
                        }";
                    }
                    .${conf_type};
                in
                ''
                  ${injectSecretsJqCmd} ${jsonPreSecretsFile} | curl --json @- -X POST ${s.baseAddress}
                ''
                /*
                  Check if we are configuring a folder which has ignore patterns.
                  If it does, write the ignore patterns to the rest API.
                */
                + lib.optionalString ((conf_type == "dirs") && (new_cfg.ignorePatterns != null)) ''
                  curl -d '{"ignore": ${builtins.toJSON new_cfg.ignorePatterns}}' -X POST ${s.ignoreAddress}?folder=${lib.strings.escapeURL new_cfg.id}
                ''
              ))
              (lib.concatStringsSep "\n")
            ]
            /*
              If we need to override devices/folders, we iterate all currently configured
              IDs, via another `curl -X GET`, and we delete all IDs that are not part of
              the Nix configured list of IDs
            */
            + lib.optionalString s.override ''
              stale_${conf_type}_ids="$(curl -X GET ${s.baseAddress} | ${jq} \
                --argjson new_ids ${lib.escapeShellArg (builtins.toJSON s.new_conf_IDs)} \
                --raw-output \
                '[.[].${s.GET_IdAttrName}] - $new_ids | .[]|@uri'
              )"
              for id in ''${stale_${conf_type}_ids}; do
                >&2 echo "Deleting stale device: $id"
                curl -X DELETE ${s.baseAddress}/$id
              done
            ''
          ))
          builtins.attrValues
          (lib.concatStringsSep "\n")
        ]
      )
    +
      /*
        Now we update the other settings defined in cleanedConfig which are not
        "folders", "devices", "guiPasswordFile", or "defaults".
      */
      (lib.pipe cleanedConfig [
        builtins.attrNames
        (lib.subtractLists [
          "folders"
          "devices"
          "guiPasswordFile"
          "defaults"
        ])
        (map (subOption: ''
          curl -X PATCH -d ${
            lib.escapeShellArg (builtins.toJSON cleanedConfig.${subOption})
          } ${curlAddressArgs "/rest/config/${subOption}"}
        ''))
        (lib.concatStringsSep "\n")
      ])
    +
      # Handle the "defaults" option separately, as it has multiple sub-endpoints.
      (lib.optionalString (cleanedConfig ? defaults) (
        lib.pipe cleanedConfig.defaults [
          builtins.attrNames
          (map (
            subOption:
            let
              # /rest/config/defaults/ignores only supports PUT
              method = if subOption == "ignores" then "PUT" else "PATCH";
            in
            ''
              curl -X ${method} -d ${
                lib.escapeShellArg (builtins.toJSON cleanedConfig.defaults.${subOption})
              } ${curlAddressArgs "/rest/config/defaults/${subOption}"}
            ''
          ))
          (lib.concatStringsSep "\n")
        ]
      ))
    +
      # Now we hash the contents of guiPasswordFile and use the result to update the gui password
      (lib.optionalString (cfg.guiPasswordFile != null) ''
        ${pkgs.mkpasswd}/bin/mkpasswd -m bcrypt --stdin <"${cfg.guiPasswordFile}" | tr -d "\n" > "$RUNTIME_DIRECTORY/password_bcrypt"
        curl -X PATCH --variable "pw_bcrypt@$RUNTIME_DIRECTORY/password_bcrypt" --expand-json '{ "password": "{{pw_bcrypt}}" }' ${curlAddressArgs "/rest/config/gui"}
      '')
    + ''
      # restart Syncthing if required
      if curl ${curlAddressArgs "/rest/config/restart-required"} |
         ${jq} -e .requiresRestart > /dev/null; then
          curl -X POST ${curlAddressArgs "/rest/system/restart"}
      fi
    ''
  );
in
{
  imports = [
    (lib.mkRemovedOptionModule [ "services" "syncthing" "useInotify" ] ''
      This option was removed because Syncthing now has the inotify functionality included under the name "fswatcher".
      It can be enabled on a per-folder basis through the web interface.
    '')
    (lib.mkRenamedOptionModule
      [ "services" "syncthing" "extraOptions" ]
      [ "services" "syncthing" "settings" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "syncthing" "folders" ]
      [ "services" "syncthing" "settings" "folders" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "syncthing" "devices" ]
      [ "services" "syncthing" "settings" "devices" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "syncthing" "options" ]
      [ "services" "syncthing" "settings" "options" ]
    )
  ]
  ++
    map
      (
        o: lib.mkRenamedOptionModule [ "services" "syncthing" "declarative" o ] [ "services" "syncthing" o ]
      )
      [
        "cert"
        "key"
        "devices"
        "folders"
        "overrideDevices"
        "overrideFolders"
        "extraOptions"
      ];

  ###### interface
  options = {
    services.syncthing = {

      enable = lib.mkEnableOption "Syncthing, a self-hosted open-source alternative to Dropbox and Bittorrent Sync";
      package = lib.mkPackageOption pkgs "syncthing" { };

      all_proxy = lib.mkOption {
        default = null;

        description = ''
          Overwrites the all_proxy environment variable for the Syncthing process to
          the given value. This is normally used to let Syncthing connect
          through a SOCKS5 proxy server.
          See <https://docs.syncthing.net/users/proxying.html>.
        '';

        example = "socks5://address.com:1234";
        type = lib.types.nullOr lib.types.str;
      };

      cert = lib.mkOption {
        default = null;

        description = ''
          Path to the `cert.pem` file, which will be copied into Syncthing's
          [configDir](#opt-services.syncthing.configDir).
        '';

        type = lib.types.nullOr lib.types.str;
      };

      configDir =
        let
          cond = lib.versionAtLeast config.system.stateVersion "19.03";
        in
        lib.mkOption {
          default = cfg.dataDir + lib.optionalString cond "/.config/syncthing";

          defaultText = lib.literalMD ''
            * if `stateVersion >= 19.03`:

                  config.${opt.dataDir} + "/.config/syncthing"
            * otherwise:

                  config.${opt.dataDir}
          '';

          description = ''
            The path where the settings and keys will exist.
          '';

          type = lib.types.path;
        };

      dataDir = lib.mkOption {
        default = "/var/lib/syncthing";

        description = ''
          The path where synchronised directories will exist.
        '';

        example = "/home/yourUser";
        type = lib.types.path;
      };

      databaseDir = lib.mkOption {
        default = cfg.configDir;
        defaultText = lib.literalExpression "config.${opt.configDir}";

        description = ''
          The directory containing the database and logs.
        '';

        type = lib.types.path;
      };

      extraFlags = lib.mkOption {
        default = [ ];

        description = ''
          Extra flags passed to the syncthing command in the service definition.
        '';

        example = [ "--reset-deltas" ];
        type = lib.types.listOf lib.types.str;
      };

      group = lib.mkOption {
        default = defaultGroup;

        description = ''
          The group to run Syncthing under.
          By default, a group named `${defaultGroup}` will be created.
        '';

        example = "yourGroup";
        type = lib.types.str;
      };

      guiAddress = lib.mkOption {
        apply = x: if lib.strings.hasPrefix "/" x then "unix://${x}" else x;
        default = "127.0.0.1:8384";

        description = ''
          The address to serve the web interface at.
        '';

        type = lib.types.str;
      };

      guiPasswordFile = lib.mkOption {
        default = null;

        description = ''
          Path to file containing the plaintext password for Syncthing's GUI.
        '';

        type = lib.types.nullOr lib.types.str;
      };

      key = lib.mkOption {
        default = null;

        description = ''
          Path to the `key.pem` file, which will be copied into Syncthing's
          [configDir](#opt-services.syncthing.configDir).
        '';

        type = lib.types.nullOr lib.types.str;
      };

      openDefaultPorts = lib.mkOption {
        default = false;

        description = ''
          Whether to open the default ports in the firewall: TCP/UDP 22000 for transfers
          and UDP 21027 for discovery.

          If multiple users are running Syncthing on this machine, you will need
          to manually open a set of ports for each instance and leave this disabled.
          Alternatively, if you are running only a single instance on this machine
          using the default ports, enable this.
        '';

        example = true;
        type = lib.types.bool;
      };

      overrideDevices = lib.mkOption {
        default = true;

        description = ''
          Whether to delete the devices which are not configured via the
          [devices](#opt-services.syncthing.settings.devices) option.
          If set to `false`, devices added via the web
          interface will persist and will have to be deleted manually.
        '';

        type = lib.types.bool;
      };

      overrideFolders = lib.mkOption {
        default = !anyAutoAccept;

        defaultText = lib.literalMD ''
          `true` unless any device has the
          [autoAcceptFolders](#opt-services.syncthing.settings.devices._name_.autoAcceptFolders)
          option set to `true`.
        '';

        description = ''
          Whether to delete the folders which are not configured via the
          [folders](#opt-services.syncthing.settings.folders) option.
          If set to `false`, folders added via the web
          interface will persist and will have to be deleted manually.
        '';

        type = lib.types.bool;
      };

      settings = lib.mkOption {
        default = { };

        description = ''
          Extra configuration options for Syncthing.
          See <https://docs.syncthing.net/users/config.html>.
          Note that this attribute set does not exactly match the documented
          xml format. Instead, this is the format of the json rest api. There
          are slight differences. For example, this xml:
          ```xml
          <options>
            <listenAddress>default</listenAddress>
            <minHomeDiskFree unit="%">1</minHomeDiskFree>
          </options>
          ```
          corresponds to the json:
          ```json
          {
            options: {
              listenAddresses = [
                "default"
              ];
              minHomeDiskFree = {
                unit = "%";
                value = 1;
              };
            };
          }
          ```
        '';

        example = {
          options.localAnnounceEnabled = false;
          gui.theme = "black";
        };

        type = lib.types.submodule {
          options = {
            # global options
            options = lib.mkOption {
              default = { };

              description = ''
                The options element contains all other global configuration options
              '';

              type = lib.types.submodule (
                { ... }:
                {
                  options = {
                    limitBandwidthInLan = lib.mkOption {
                      default = null;

                      description = ''
                        Whether to apply bandwidth limits to devices in the same broadcast domain as the local device.
                      '';

                      type = lib.types.nullOr lib.types.bool;
                    };

                    localAnnounceEnabled = lib.mkOption {
                      default = null;

                      description = ''
                        Whether to send announcements to the local LAN, also use such announcements to find other devices.
                      '';

                      type = lib.types.nullOr lib.types.bool;
                    };

                    localAnnouncePort = lib.mkOption {
                      default = null;

                      description = ''
                        The port on which to listen and send IPv4 broadcast announcements to.
                      '';

                      type = lib.types.nullOr lib.types.port;
                    };

                    maxFolderConcurrency = lib.mkOption {
                      default = null;

                      description = ''
                        This option controls how many folders may concurrently be in I/O-intensive operations such as syncing or scanning.
                        The mechanism is described in detail in a [separate chapter](https://docs.syncthing.net/advanced/option-max-concurrency.html).
                      '';

                      type = lib.types.nullOr lib.types.int;
                    };

                    relaysEnabled = lib.mkOption {
                      default = null;

                      description = ''
                        When true, relays will be connected to and potentially used for device to device connections.
                      '';

                      type = lib.types.nullOr lib.types.bool;
                    };

                    urAccepted = lib.mkOption {
                      default = null;

                      description = ''
                        Whether the user has accepted to submit anonymous usage data.
                        The default, 0, mean the user has not made a choice, and Syncthing will ask at some point in the future.
                        "-1" means no, a number above zero means that that version of usage reporting has been accepted.
                      '';

                      type = lib.types.nullOr lib.types.int;
                    };
                  };

                  freeformType = settingsFormat.type;
                }
              );
            };

            # device settings
            devices = lib.mkOption {
              default = { };

              description = ''
                Peers/devices which Syncthing should communicate with.

                Note that you can still add devices manually, but those changes
                will be reverted on restart if [overrideDevices](#opt-services.syncthing.overrideDevices)
                is enabled.
              '';

              example = {
                bigbox = {
                  addresses = [ "tcp://192.168.0.10:51820" ];
                  id = "7CFNTQM-IMTJBHJ-3UWRDIU-ZGQJFR6-VCXZ3NB-XUH3KZO-N52ITXR-LAIYUAU";
                };
              };

              type = lib.types.attrsOf (
                lib.types.submodule (
                  { name, ... }:
                  {
                    options = {

                      autoAcceptFolders = lib.mkOption {
                        default = false;

                        description = ''
                          Automatically create or share folders that this device advertises at the default path.
                          See <https://docs.syncthing.net/users/config.html?highlight=autoaccept#config-file-format>.
                        '';

                        type = lib.types.bool;
                      };

                      id = lib.mkOption {
                        description = ''
                          The device ID. See <https://docs.syncthing.net/dev/device-ids.html>.
                        '';

                        type = lib.types.str;
                      };

                      name = lib.mkOption {
                        default = name;

                        description = ''
                          The name of the device.
                        '';

                        type = lib.types.str;
                      };

                    };

                    freeformType = settingsFormat.type;
                  }
                )
              );
            };

            # folder settings
            folders = lib.mkOption {
              default = { };

              description = ''
                Folders which should be shared by Syncthing.

                Note that you can still add folders manually, but those changes
                will be reverted on restart if [overrideFolders](#opt-services.syncthing.overrideFolders)
                is enabled.
              '';

              example = lib.literalExpression ''
                {
                  "/home/user/sync" = {
                    id = "syncme";
                    devices = [ "bigbox" ];
                  };
                }
              '';

              type = lib.types.attrsOf (
                lib.types.submodule (
                  { name, ... }:
                  {
                    options = {

                      enable = lib.mkOption {
                        default = true;

                        description = ''
                          Whether to share this folder.
                          This option is useful when you want to define all folders
                          in one place, but not every machine should share all folders.
                        '';

                        type = lib.types.bool;
                      };

                      copyOwnershipFromParent = lib.mkOption {
                        default = false;

                        description = ''
                          On Unix systems, tries to copy file/folder ownership from the parent directory (the directory it’s located in).
                          Requires running Syncthing as a privileged user, or granting it additional capabilities (e.g. CAP_CHOWN on Linux).
                        '';

                        type = lib.types.bool;
                      };

                      devices = lib.mkOption {
                        default = [ ];

                        description = ''
                          The devices this folder should be shared with. Each device must
                          be defined in the [devices](#opt-services.syncthing.settings.devices) option.

                          A list of either strings or attribute sets, where values
                          are device names or device configurations.
                        '';

                        type = lib.types.listOf (
                          lib.types.oneOf [
                            lib.types.str
                            (lib.types.submodule (
                              { ... }:
                              {
                                options = {
                                  encryptionPasswordFile = lib.mkOption {
                                    default = null;

                                    description = ''
                                      Path to encryption password. If set, the file will be read during
                                      service activation, without being embedded in derivation.
                                    '';

                                    type = lib.types.nullOr lib.types.externalPath;
                                  };

                                  name = lib.mkOption {
                                    default = null;

                                    description = ''
                                      The name of a device defined in the
                                      [devices](#opt-services.syncthing.settings.devices)
                                      option.
                                    '';

                                    type = lib.types.str;
                                  };
                                };

                                freeformType = settingsFormat.type;
                              }
                            ))
                          ]
                        );
                      };

                      id = lib.mkOption {
                        default = name;

                        description = ''
                          The ID of the folder. Must be the same on all devices.
                        '';

                        type = lib.types.str;
                      };

                      ignorePatterns = lib.mkOption {
                        default = null;

                        description = ''
                          Syncthing can be configured to ignore certain files in a folder using ignore patterns.
                          Enter them as a list of strings, one string per line.
                          See the Syncthing documentation for syntax: <https://docs.syncthing.net/users/ignoring.html>
                          Patterns set using the WebUI will be overridden if you define this option.
                          If you want to override the ignore patterns to be empty, use `ignorePatterns = []`.
                          Deleting the `ignorePatterns` option will not remove the patterns from Syncthing automatically
                          because patterns are only handled by the module if this option is defined. Either use
                          `ignorePatterns = []` before deleting the option or remove the patterns afterwards using the WebUI.
                        '';

                        example = [
                          "// This is a comment"
                          "*.part // Firefox downloads and other things"
                          "*.crdownload // Chrom(ium|e) downloads"
                        ];

                        type = lib.types.nullOr (lib.types.listOf lib.types.str);
                      };

                      label = lib.mkOption {
                        default = name;

                        description = ''
                          The label of the folder.
                        '';

                        type = lib.types.str;
                      };

                      path = lib.mkOption {
                        default = name;

                        description = ''
                          The path to the folder which should be shared.
                          Only absolute paths (starting with `/`) and paths relative to
                          the [user](#opt-services.syncthing.user)'s home directory
                          (starting with `~/`) are allowed.
                        '';

                        # TODO for release 23.05: allow relative paths again and set
                        # working directory to cfg.dataDir
                        type = lib.types.str // {
                          check = x: lib.types.str.check x && (lib.substring 0 1 x == "/" || lib.substring 0 2 x == "~/");
                          description = lib.types.str.description + " starting with / or ~/";
                        };
                      };

                      type = lib.mkOption {
                        default = "sendreceive";

                        description = ''
                          Controls how the folder is handled by Syncthing.
                          See <https://docs.syncthing.net/users/config.html#config-option-folder.type>.
                        '';

                        type = lib.types.enum [
                          "sendreceive"
                          "sendonly"
                          "receiveonly"
                          "receiveencrypted"
                        ];
                      };

                      versioning = lib.mkOption {
                        default = null;

                        description = ''
                          How to keep changed/deleted files with Syncthing.
                          There are 4 different types of versioning with different parameters.
                          See <https://docs.syncthing.net/users/versioning.html>.
                        '';

                        example = lib.literalExpression ''
                          [
                            {
                              versioning = {
                                type = "simple";
                                params.keep = "10";
                              };
                            }
                            {
                              versioning = {
                                type = "trashcan";
                                params.cleanoutDays = "1000";
                              };
                            }
                            {
                              versioning = {
                                type = "staggered";
                                fsPath = "/syncthing/backup";
                                params = {
                                  cleanInterval = "3600";
                                  maxAge = "31536000";
                                };
                              };
                            }
                            {
                              versioning = {
                                type = "external";
                                params.versionsPath = pkgs.writers.writeBash "backup" '''
                                  folderpath="$1"
                                  filepath="$2"
                                  rm -rf "$folderpath/$filepath"
                                ''';
                              };
                            }
                          ]
                        '';

                        type = lib.types.nullOr (
                          lib.types.submodule {
                            options = {
                              type = lib.mkOption {
                                description = ''
                                  The type of versioning.
                                  See <https://docs.syncthing.net/users/versioning.html>.
                                '';

                                type = lib.types.enum [
                                  "external"
                                  "simple"
                                  "staggered"
                                  "trashcan"
                                ];
                              };
                            };

                            freeformType = settingsFormat.type;
                          }
                        );
                      };
                    };

                    freeformType = settingsFormat.type;
                  }
                )
              );
            };

          };

          freeformType = settingsFormat.type;
        };
      };

      systemService = lib.mkOption {
        default = true;

        description = ''
          Whether to auto-launch Syncthing as a system service.
        '';

        type = lib.types.bool;
      };

      user = lib.mkOption {
        default = defaultUser;

        description = ''
          The user to run Syncthing as.
          By default, a user named `${defaultUser}` will be created whose home
          directory is [dataDir](#opt-services.syncthing.dataDir).
        '';

        example = "yourUser";
        type = lib.types.str;
      };
    };
  };

  ###### implementation
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !(cfg.overrideFolders && anyAutoAccept);

        message = ''
          services.syncthing.overrideFolders will delete auto-accepted folders
          from the configuration, creating path conflicts.
        '';
      }
      {
        assertion = (lib.hasAttrByPath [ "gui" "password" ] cfg.settings) -> cfg.guiPasswordFile == null;

        message = ''
          Please use only one of services.syncthing.settings.gui.password or services.syncthing.guiPasswordFile.
        '';
      }
    ];

    environment.systemPackages = [ cfg.package ];

    networking.firewall = lib.mkIf cfg.openDefaultPorts {
      allowedTCPPorts = [ 22000 ];

      allowedUDPPorts = [
        21027
        22000
      ];
    };

    systemd.packages = [ cfg.package ];

    systemd.services = {
      # upstream reference:
      # https://github.com/syncthing/syncthing/blob/main/etc/linux-systemd/system/syncthing%40.service
      syncthing = lib.mkIf cfg.systemService {
        after = [ "network.target" ];
        description = "Syncthing service";

        environment = {
          inherit (cfg) all_proxy;
          STNORESTART = "yes";
          STNOUPGRADE = "yes";
        }
        // config.networking.proxy.envVars;

        serviceConfig = {
          CapabilityBoundingSet = [
            "~CAP_SYS_PTRACE"
            "~CAP_SYS_ADMIN"
            "~CAP_SETGID"
            "~CAP_SETUID"
            "~CAP_SETPCAP"
            "~CAP_SYS_TIME"
            "~CAP_KILL"
          ];

          ExecStart =
            let
              args = lib.escapeShellArgs (
                (lib.cli.toCommandLineGNU { } {
                  "config" = cfg.configDir;
                  "data" = cfg.databaseDir;
                  "gui-address" = cfg.guiAddress;
                  "no-browser" = true;
                })
                ++ cfg.extraFlags
              );
            in
            "${lib.getExe cfg.package} ${args}";

          ExecStartPre =
            lib.mkIf (cfg.cert != null || cfg.key != null)
              "+${pkgs.writers.writeBash "syncthing-copy-keys" ''
                install -dm700 -o ${cfg.user} -g ${cfg.group} ${cfg.configDir}
                ${lib.optionalString (cfg.cert != null) ''
                  install -Dm644 -o ${cfg.user} -g ${cfg.group} ${toString cfg.cert} ${cfg.configDir}/cert.pem
                ''}
                ${lib.optionalString (cfg.key != null) ''
                  install -Dm600 -o ${cfg.user} -g ${cfg.group} ${toString cfg.key} ${cfg.configDir}/key.pem
                ''}
              ''}";

          Group = cfg.group;
          MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateMounts = true;
          PrivateTmp = true;
          PrivateUsers = true;
          ProtectControlGroups = true;
          ProtectHostname = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          Restart = "on-failure";
          RestartForceExitStatus = "3 4";
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          RuntimeDirectory = "syncthing";
          SuccessExitStatus = "3 4";
          User = cfg.user;
        };

        wantedBy = [ "multi-user.target" ];
      };

      syncthing-init = lib.mkIf (cleanedConfig != { }) {
        after = [ "syncthing.service" ];
        description = "Syncthing configuration updater";
        requisite = [ "syncthing.service" ];

        serviceConfig = {
          ExecStart = updateConfig;
          RemainAfterExit = true;
          RuntimeDirectory = "syncthing-init";
          Type = "oneshot";
          User = cfg.user;
        };

        wantedBy = [ "multi-user.target" ];
      };
    };

    users.groups = lib.mkIf (cfg.systemService && cfg.group == defaultGroup) {
      ${defaultGroup}.gid = config.ids.gids.syncthing;
    };

    users.users = lib.mkIf (cfg.systemService && cfg.user == defaultUser) {
      ${defaultUser} = {
        createHome = true;
        description = "Syncthing daemon user";
        group = cfg.group;
        home = cfg.dataDir;
        uid = config.ids.uids.syncthing;
      };
    };
  };

  meta.maintainers = with lib.maintainers; [
    doronbehar
    seudonym
  ];
}
