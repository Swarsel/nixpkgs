{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) types;
  inherit (lib.attrsets) mapAttrs' mapAttrsToList nameValuePair;
  inherit (lib.generators) toINI;
  inherit (lib.modules) mkDefault mkIf mkRemovedOptionModule;
  inherit (lib.options) literalExpression mkEnableOption mkOption;
  inherit (lib.strings) concatStringsSep;

  cfg = config.services.keyd;

  keyboardOptions = {
    options = {
      extraConfig = mkOption {
        default = "";

        description = ''
          Extra configuration that is appended to the end of the file.
          **Do not** write `ids` section here, use a separate option for it.
          You can use this option to define compound layers that must always be defined after the layer they are comprised.
        '';

        example = ''
          [control+shift]
          h = left
        '';

        type = types.lines;
      };

      ids = mkOption {
        default = [ "*" ];

        description = ''
          Device identifiers, as shown by {manpage}`keyd(1)`.
        '';

        example = [
          "*"
          "-0123:0456"
        ];

        type = with types; listOf str;
      };

      settings = mkOption {
        inherit (pkgs.formats.ini { }) type;
        default = { };

        description = ''
          Configuration, except `ids` section, that is written to {file}`/etc/keyd/<keyboard>.conf`.
          Appropriate names can be used to write non-alpha keys, for example "equal" instead of "=" sign (see <https://github.com/NixOS/nixpkgs/issues/236622>).
          See <https://github.com/rvaiya/keyd> how to configure.
        '';

        example = {
          main = {
            capslock = "overload(control, esc)";
            rightalt = "layer(rightalt)";
          };

          rightalt = {
            h = "left";
            j = "down";
            k = "up";
            l = "right";
          };
        };
      };
    };
  };
in
{
  imports = [
    (lib.mkRemovedOptionModule [ "services" "keyd" "ids" ]
      "Use keyboards.<filename>.ids instead. If you don't need a multi-file configuration, just add keyboards.default before the ids. See https://github.com/NixOS/nixpkgs/pull/243271."
    )
    (lib.mkRemovedOptionModule [ "services" "keyd" "settings" ]
      "Use keyboards.<filename>.settings instead. If you don't need a multi-file configuration, just add keyboards.default before the settings. See https://github.com/NixOS/nixpkgs/pull/243271."
    )
  ];

  options.services.keyd = {
    enable = mkEnableOption "keyd, a key remapping daemon";
    package = lib.mkPackageOption pkgs "keyd" { };

    keyboards = mkOption {
      default = { };

      description = ''
        Configuration for one or more device IDs. Corresponding files in the /etc/keyd/ directory are created according to the name of the keys (like `default` or `externalKeyboard`).
      '';

      example = literalExpression ''
        {
          default = {
            ids = [ "*" ];
            settings = {
              main = {
                capslock = "overload(control, esc)";
              };
            };
          };
          externalKeyboard = {
            ids = [ "1ea7:0907" ];
            settings = {
              main = {
                esc = capslock;
              };
            };
          };
        }
      '';

      type = with types; attrsOf (submodule keyboardOptions);
    };
  };

  config = mkIf cfg.enable {
    # Creates separate files in the `/etc/keyd/` directory for each key in the dictionary
    environment.etc = mapAttrs' (
      name: options:
      nameValuePair "keyd/${name}.conf" {
        text = ''
          [ids]
          ${concatStringsSep "\n" options.ids}

          ${toINI { } options.settings}
          ${options.extraConfig}
        '';
      }
    ) cfg.keyboards;

    hardware.uinput.enable = mkDefault true;

    systemd.services.keyd = {
      description = "Keyd remapping daemon";
      documentation = [ "man:keyd(1)" ];

      restartTriggers = mapAttrsToList (
        name: _options: config.environment.etc."keyd/${name}.conf".source
      ) cfg.keyboards;

      serviceConfig = {
        # Hardening
        CapabilityBoundingSet = [
          "CAP_SYS_NICE"
          "CAP_IPC_LOCK"
        ];

        DeviceAllow = [
          "char-input rw"
          "/dev/uinput rw"
        ];

        ExecStart = lib.getExe cfg.package;
        IPAddressDeny = [ "any" ];
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateMounts = true;
        PrivateNetwork = true;
        PrivateTmp = true;
        PrivateUsers = false;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        Restart = "always";
        RestrictAddressFamilies = [ "AF_UNIX" ];
        RestrictNamespaces = true;
        RestrictSUIDSGID = true;
        RuntimeDirectory = "keyd";

        # TODO investigate why it doesn't work propeprly with DynamicUser
        # See issue: https://github.com/NixOS/nixpkgs/issues/226346
        # DynamicUser = true;
        SupplementaryGroups = [
          config.users.groups.input.name
          config.users.groups.uinput.name
        ];

        SystemCallFilter = [
          "nice"
          "@system-service"
          "~@privileged"
        ];

        UMask = "0077";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
