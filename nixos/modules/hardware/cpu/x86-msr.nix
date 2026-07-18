{
  config,
  lib,
  options,
  ...
}:
let
  inherit (builtins) hasAttr;
  inherit (lib) mkIf;
  cfg = config.hardware.cpu.x86.msr;
  opt = options.hardware.cpu.x86.msr;
  defaultGroup = "msr";
  isDefaultGroup = cfg.group == defaultGroup;
  set = "to set for devices of the `msr` kernel subsystem.";

  # Generates `foo=bar` parameters to pass to the kernel.
  # If `module = baz` is passed, generates `baz.foo=bar`.
  # Adds double quotes on demand to handle `foo="bar baz"`.
  kernelParam =
    {
      module ? null,
    }:
    name: value:
    assert lib.asserts.assertMsg (
      !lib.strings.hasInfix "=" name
    ) "kernel parameter cannot have '=' in name";
    let
      key = (if module == null then "" else module + ".") + name;
      valueString = lib.generators.mkValueStringDefault { } value;
      quotedValueString =
        if lib.strings.hasInfix " " valueString then
          lib.strings.escape [ "\"" ] valueString
        else
          valueString;
    in
    "${key}=${quotedValueString}";
  msrKernelParam = kernelParam { module = "msr"; };
in
{
  options.hardware.cpu.x86.msr =
    with lib.options;
    with lib.types;
    {
      enable = mkEnableOption "the `msr` (Model-Specific Registers) kernel module and configure `udev` rules for its devices (usually `/dev/cpu/*/msr`)";

      group = mkOption {
        default = defaultGroup;
        description = "Group ${set}";
        example = "users";
        type = str;
      };

      mode = mkOption {
        default = "0640";
        description = "Mode ${set}";
        example = "0660";
        type = str;
      };

      owner = mkOption {
        default = "root";
        description = "Owner ${set}";
        example = "alice";
        type = str;
      };

      settings = mkOption {
        default = { };
        description = "Parameters for the `msr` kernel module.";

        type = submodule {
          options.allow-writes = mkOption {
            default = null;
            description = "Whether to allow writes to MSRs (`\"on\"`) or not (`\"off\"`).";

            type = nullOr (enum [
              "on"
              "off"
            ]);
          };

          freeformType = attrsOf (oneOf [
            bool
            int
            str
          ]);
        };
      };
    };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = hasAttr cfg.owner config.users.users;
        message = "Owner '${cfg.owner}' set in `${opt.owner}` is not configured via `${options.users.users}.\"${cfg.owner}\"`.";
      }
      {
        assertion = isDefaultGroup || (hasAttr cfg.group config.users.groups);
        message = "Group '${cfg.group}' set in `${opt.group}` is not configured via `${options.users.groups}.\"${cfg.group}\"`.";
      }
    ];

    boot = {
      kernelModules = [ "msr" ];

      kernelParams = lib.attrsets.mapAttrsToList msrKernelParam (
        lib.attrsets.filterAttrs (_: value: value != null) cfg.settings
      );
    };

    services.udev.extraRules = ''
      SUBSYSTEM=="msr", OWNER="${cfg.owner}", GROUP="${cfg.group}", MODE="${cfg.mode}"
    '';

    users.groups.${cfg.group} = mkIf isDefaultGroup { };
  };

  meta = {
    maintainers = with lib.maintainers; [ lorenzleutgeb ];
  };
}
