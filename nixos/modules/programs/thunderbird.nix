{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.thunderbird;
  policyFormat = pkgs.formats.json { };
  policyDoc = "https://github.com/thunderbird/policy-templates";
in
{
  options.programs.thunderbird = {
    enable = lib.mkEnableOption "Thunderbird mail client";
    package = lib.mkPackageOption pkgs "thunderbird" { };

    policies = lib.mkOption {
      default = { };

      description = ''
        Group policies to install.

        See [Thunderbird's documentation](${policyDoc})
        for a list of available options.

        This can be used to install extensions declaratively! Check out the
        documentation of the `ExtensionSettings` policy for details.

      '';

      type = policyFormat.type;
    };

    preferences = lib.mkOption {
      default = { };

      description = ''
        Preferences to set from `about:config`.

        Some of these might be able to be configured more ergonomically
        using policies.
      '';

      type =
        with lib.types;
        attrsOf (oneOf [
          bool
          int
          str
        ]);
    };

    preferencesStatus = lib.mkOption {
      default = "locked";

      description = ''
        The status of `thunderbird.preferences`.

        `status` can assume the following values:
        - `"default"`: Preferences appear as default.
        - `"locked"`: Preferences appear as default and can't be changed.
        - `"user"`: Preferences appear as changed.
        - `"clear"`: Value has no effect. Resets to factory defaults on each startup.
      '';

      type = lib.types.enum [
        "default"
        "locked"
        "user"
        "clear"
      ];
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc =
      let
        policiesJSON = policyFormat.generate "thunderbird-policies.json" { inherit (cfg) policies; };
      in
      lib.mkIf (cfg.policies != { }) { "thunderbird/policies/policies.json".source = policiesJSON; };

    environment.systemPackages = [ cfg.package ];

    programs.thunderbird.policies = {
      DisableAppUpdate = true;

      Preferences = builtins.mapAttrs (_: value: {
        Status = cfg.preferencesStatus;
        Value = value;
      }) cfg.preferences;
    };
  };

  meta.maintainers = with lib.maintainers; [ nydragon ];
}
