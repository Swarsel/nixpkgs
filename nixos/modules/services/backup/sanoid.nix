{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.sanoid;

  datasetSettingsType =
    with lib.types;
    (attrsOf (
      nullOr (oneOf [
        str
        int
        bool
        (listOf str)
      ])
    ))
    // {
      description = "dataset/template options";
    };

  commonOptions = {
    autoprune = lib.mkOption {
      default = null;
      description = "Whether to automatically prune old snapshots.";
      type = with lib.types; nullOr bool;
    };

    autosnap = lib.mkOption {
      default = null;
      description = "Whether to automatically take snapshots.";
      type = with lib.types; nullOr bool;
    };

    daily = lib.mkOption {
      default = null;
      description = "Number of daily snapshots.";
      type = with lib.types; nullOr ints.unsigned;
    };

    force_post_snapshot_script = lib.mkOption {
      default = null;
      description = "Whether to run the post script if the pre script fails";
      type = with lib.types; nullOr bool;
    };

    hourly = lib.mkOption {
      default = null;
      description = "Number of hourly snapshots.";
      type = with lib.types; nullOr ints.unsigned;
    };

    monthly = lib.mkOption {
      default = null;
      description = "Number of monthly snapshots.";
      type = with lib.types; nullOr ints.unsigned;
    };

    no_inconsistent_snapshot = lib.mkOption {
      default = null;
      description = "Whether to take a snapshot if the pre script fails";
      type = with lib.types; nullOr bool;
    };

    post_snapshot_script = lib.mkOption {
      default = null;
      description = "Script to run after taking snapshot.";
      type = with lib.types; nullOr str;
    };

    pre_snapshot_script = lib.mkOption {
      default = null;
      description = "Script to run before taking snapshot.";
      type = with lib.types; nullOr str;
    };

    pruning_script = lib.mkOption {
      default = null;
      description = "Script to run after pruning snapshot.";
      type = with lib.types; nullOr str;
    };

    script_timeout = lib.mkOption {
      default = null;
      description = "Time limit for pre/post/pruning script execution time (<=0 for infinite).";
      type = with lib.types; nullOr int;
    };

    yearly = lib.mkOption {
      default = null;
      description = "Number of yearly snapshots.";
      type = with lib.types; nullOr ints.unsigned;
    };
  };

  datasetOptions = rec {
    processChildrenOnly = process_children_only;

    process_children_only = lib.mkOption {
      default = false;
      description = "Whether to only snapshot child datasets if recursing.";
      type = lib.types.bool;
    };

    recursive = lib.mkOption {
      default = false;

      description = ''
        Whether to recursively snapshot dataset children.
        You can also set this to `"zfs"` to handle datasets
        recursively in an atomic way without the possibility to
        override settings for child datasets.
      '';

      type =
        with lib.types;
        oneOf [
          bool
          (enum [ "zfs" ])
        ];
    };

    useTemplate = use_template;

    use_template = lib.mkOption {
      default = [ ];
      description = "Names of the templates to use for this dataset.";

      type = lib.types.listOf (
        lib.types.str
        // {
          check = (lib.types.enum (lib.attrNames cfg.templates)).check;
          description = "configured template name";
        }
      );
    };
  };

  # Extract unique dataset names
  datasets = lib.unique (lib.attrNames cfg.datasets);

  # Function to build "zfs allow" and "zfs unallow" commands for the
  # filesystems we've delegated permissions to.
  buildAllowCommand =
    zfsAction: permissions: dataset:
    lib.escapeShellArgs [
      # Here we explicitly use the booted system to guarantee the stable API needed by ZFS
      "-+/run/booted-system/sw/bin/zfs"
      zfsAction
      "sanoid"
      (lib.concatStringsSep "," permissions)
      dataset
    ];

  configFile =
    let
      mkValueString =
        v: if lib.isList v then lib.concatStringsSep "," v else lib.generators.mkValueStringDefault { } v;

      mkKeyValue =
        k: v:
        if v == null then
          ""
        else if k == "processChildrenOnly" then
          ""
        else if k == "useTemplate" then
          ""
        else
          lib.generators.mkKeyValueDefault { inherit mkValueString; } "=" k v;
    in
    lib.generators.toINI { inherit mkKeyValue; } cfg.settings;

in
{

  # Interface

  options.services.sanoid = {
    enable = lib.mkEnableOption "Sanoid ZFS snapshotting service";
    package = lib.mkPackageOption pkgs "sanoid" { };

    datasets = lib.mkOption {
      default = { };
      description = "Datasets to snapshot.";

      type = lib.types.attrsOf (
        lib.types.submodule (
          { config, options, ... }:
          {
            options = commonOptions // datasetOptions;

            config.process_children_only = lib.modules.mkAliasAndWrapDefsWithPriority lib.id (
              options.processChildrenOnly or { }
            );

            config.use_template = lib.modules.mkAliasAndWrapDefsWithPriority lib.id (
              options.useTemplate or { }
            );

            freeformType = datasetSettingsType;
          }
        )
      );
    };

    extraArgs = lib.mkOption {
      default = [ ];

      description = ''
        Extra arguments to pass to sanoid. See
        <https://github.com/jimsalterjrs/sanoid/#sanoid-command-line-options>
        for allowed options.
      '';

      example = [
        "--verbose"
        "--readonly"
        "--debug"
      ];

      type = lib.types.listOf lib.types.str;
    };

    interval = lib.mkOption {
      default = "hourly";

      description = ''
        Run sanoid at this interval. The default is to run hourly.

        The format is described in
        {manpage}`systemd.time(7)`.
      '';

      example = "daily";
      type = lib.types.str;
    };

    settings = lib.mkOption {
      description = ''
        Free-form settings written directly to the config file. See
        <https://github.com/jimsalterjrs/sanoid/blob/master/sanoid.defaults.conf>
        for allowed values.
      '';

      type = lib.types.attrsOf datasetSettingsType;
    };

    templates = lib.mkOption {
      default = { };
      description = "Templates for datasets.";

      type = lib.types.attrsOf (
        lib.types.submodule {
          options = commonOptions;
          freeformType = datasetSettingsType;
        }
      );
    };
  };

  # Implementation

  config = lib.mkIf cfg.enable {
    environment.etc."sanoid/sanoid.conf".text = configFile;

    services.sanoid.settings = lib.mkMerge [
      (lib.mapAttrs' (d: v: lib.nameValuePair ("template_" + d) v) cfg.templates)
      (lib.mapAttrs (d: v: v) cfg.datasets)
    ];

    systemd.services.sanoid = {
      after = [ "zfs.target" ];
      description = "Sanoid snapshot service";
      # Prevents missing snapshots during DST changes
      environment.TZ = "UTC";

      serviceConfig = {
        CacheDirectory = "sanoid";
        DynamicUser = true;

        ExecStart = lib.escapeShellArgs (
          [
            "${cfg.package}/bin/sanoid"
            "--cron"
            "--configdir"
            "/etc/sanoid"
          ]
          ++ cfg.extraArgs
        );

        ExecStartPre = (
          map (buildAllowCommand "allow" [
            "snapshot"
            "mount"
            "destroy"
          ]) datasets
        );

        ExecStopPost = (
          map (buildAllowCommand "unallow" [
            "snapshot"
            "mount"
            "destroy"
          ]) datasets
        );

        Group = "sanoid";
        RuntimeDirectory = "sanoid";
        User = "sanoid";
      };

      startAt = cfg.interval;
    };
  };

  meta.maintainers = with lib.maintainers; [ lopsided98 ];
}
