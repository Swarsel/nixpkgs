{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.below;
  cfgContents = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (n: v: ''${n} = "${v}"'') (
      lib.filterAttrs (_k: v: v != null) {
        cgroup_filter_out = cfg.cgroupFilterOut;
        log_dir = cfg.dirs.log;
        store_dir = cfg.dirs.store;
      }
    )
  );

  mkDisableOption =
    n:
    lib.mkOption {
      default = true;
      description = "Whether to enable ${n}.";
      type = lib.types.bool;
    };
  optionalType =
    ty: x:
    lib.mkOption (
      x
      // {
        default = null;
        description = x.description;
        type = (lib.types.nullOr ty);
      }
    );
  optionalPath = optionalType lib.types.path;
  optionalStr = optionalType lib.types.str;
  optionalInt = optionalType lib.types.int;
in
{
  options = {
    services.below = {
      enable = lib.mkEnableOption "'below' resource monitor";

      cgroupFilterOut = optionalStr {
        description = "A regexp matching the full paths of cgroups whose data shouldn't be collected";
        example = "user.slice.*";
      };

      collect = {
        diskStats = mkDisableOption "dist_stat collection";
        exitStats = mkDisableOption "eBPF-based exitstats";
        ioStats = lib.mkEnableOption "io.stat collection for cgroups";
      };

      compression.enable = lib.mkEnableOption "data compression";

      dirs = {
        log = optionalPath { description = "Where to store below's logs"; };

        store = optionalPath {
          description = "Where to store below's data";
          example = "/var/lib/below";
        };
      };

      retention = {
        size = optionalInt {
          description = ''
            Size limit for below's data, in bytes. Data is deleted oldest-first, in 24h 'shards'.

            ::: {.note}
            The size limit may be exceeded by at most the size of the active shard, as:
            - the active shard cannot be deleted;
            - the size limit is only enforced when a new shard is created.
            :::
          '';
        };

        time = optionalInt {
          description = ''
            Retention time, in seconds.

            ::: {.note}
            As data is stored in 24 hour shards which are discarded as a whole,
            only data expired by 24h (or more) is guaranteed to be discarded.
            :::

            ::: {.note}
            If `retention.size` is set, data may be discarded earlier than the specified time.
            :::
          '';
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # /etc/below.conf is also referred to by the `below` CLI tool,
    #  so this can't be a store-only file whose path is passed to the service
    environment.etc."below/below.conf".text = cfgContents;
    environment.systemPackages = [ pkgs.below ];

    systemd = {
      packages = [ pkgs.below ];

      services.below = {
        restartTriggers = [ cfgContents ];

        serviceConfig.ExecStart = [
          ""
          (
            "${lib.getExe pkgs.below} record "
            + (lib.concatStringsSep " " (
              lib.optional (!cfg.collect.diskStats) "--disable-disk-stat"
              ++ lib.optional cfg.collect.ioStats "--collect-io-stat"
              ++ lib.optional (!cfg.collect.exitStats) "--disable-exitstats"
              ++ lib.optional cfg.compression.enable "--compress"
              ++

                lib.optional (cfg.retention.size != null) "--store-size-limit ${toString cfg.retention.size}"
              ++ lib.optional (cfg.retention.time != null) "--retain-for-s ${toString cfg.retention.time}"
            ))
          )
        ];

        # Workaround for https://github.com/NixOS/nixpkgs/issues/81138
        wantedBy = [ "multi-user.target" ];
      };
    };
  };

  meta.maintainers = with lib.maintainers; [ nicoo ];
}
