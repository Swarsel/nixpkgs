{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

# See http://christophe.varoqui.free.fr/usage.html and
# https://github.com/opensvc/multipath-tools/blob/master/multipath/multipath.conf.5

let
  cfg = config.services.multipath;

  indentLines =
    n: str:
    concatStringsSep "\n" (
      map (line: "${fixedWidthString n " " " "}${line}") (filter (x: x != "") (splitString "\n" str))
    );

  addCheckDesc =
    desc: elemType: check:
    types.addCheck elemType check // { description = "${elemType.description} (with check: ${desc})"; };
  hexChars = stringToCharacters "0123456789abcdef";
  isHexString = s: all (c: elem c hexChars) (stringToCharacters (toLower s));
  hexStr = addCheckDesc "hexadecimal string" types.str isHexString;

in
{

  options.services.multipath = with types; {

    enable = mkEnableOption "the device mapper multipath (DM-MP) daemon";
    package = mkPackageOption pkgs "multipath-tools" { };

    blacklist = mkOption {
      default = null;

      description = ''
        This section defines which devices should be excluded from the
        multipath topology discovery.
      '';

      type = nullOr str;
    };

    blacklist_exceptions = mkOption {
      default = null;

      description = ''
        This section defines which devices should be included in the
        multipath topology discovery, despite being listed in the
        blacklist section.
      '';

      type = nullOr str;
    };

    defaults = mkOption {
      default = null;

      description = ''
        This section defines default values for attributes which are used
        whenever no values are given in the appropriate device or multipath
        sections.
      '';

      type = nullOr str;
    };

    devices = mkOption {
      default = [ ];

      description = ''
        This option allows you to define arrays for use in multipath
        groups.
      '';

      example = literalExpression ''
        [
          {
            vendor = "\"COMPELNT\"";
            product = "\"Compellent Vol\"";
            path_checker = "tur";
            no_path_retry = "queue";
            max_sectors_kb = 256;
          }, ...
        ]
      '';

      type = listOf (submodule {
        options = {

          alias_prefix = mkOption {
            default = null;
            description = "The user_friendly_names prefix to use for this device type, instead of the default mpath";
            type = nullOr str;
          };

          all_tg_pt = mkOption {
            default = null;
            description = "Set the 'all targets ports' flag when registering keys with mpathpersist";
            type = nullOr str;
          };

          deferred_remove = mkOption {
            default = null; # real default: "no"

            description = ''
              If set to "yes", multipathd will do a deferred remove instead of a
              regular remove when the last path device has been deleted. This means
              that if the multipath device is still in use, it will be freed when
              the last user closes it. If path is added to the multipath device
              before the last user closes it, the deferred remove will be canceled.
            '';

            type = nullOr (enum [
              "yes"
              "no"
            ]);
          };

          delay_wait_checks = mkOption {
            default = null;
            description = "This option is deprecated, and mapped to san_path_err_recovery_time";
            type = nullOr str;
          };

          delay_watch_checks = mkOption {
            default = null;
            description = "This option is deprecated, and mapped to san_path_err_forget_rate";
            type = nullOr str;
          };

          detect_checker = mkOption {
            default = null; # real default: "yes"

            description = ''
              If set to "yes", multipath will try to detect if the device supports
              SCSI-3 ALUA. If so, the device will automatically use the tur checker.
              If set to "no", the checker will be selected as usual.
            '';

            type = nullOr (enum [
              "yes"
              "no"
            ]);
          };

          detect_prio = mkOption {
            default = null; # real default: "yes"

            description = ''
              If set to "yes", multipath will try to detect if the device supports
              SCSI-3 ALUA. If so, the device will automatically use the sysfs
              prioritizer if the required sysf attributes access_state and
              preferred_path are supported, or the alua prioritizer if not. If set
              to "no", the prioritizer will be selected as usual.
            '';

            type = nullOr (enum [
              "yes"
              "no"
            ]);
          };

          dev_loss_tmo = mkOption {
            default = null; # real default: 600

            description = ''
              Specify the number of seconds the SCSI layer will wait after a problem has
              been detected on a FC remote port before removing it from the system. This
              can be set to "infinity" which sets it to the max value of 2147483647
              seconds, or 68 years. It will be automatically adjusted to the overall
              retry interval no_path_retry * polling_interval
              if a number of retries is given with no_path_retry and the
              overall retry interval is longer than the specified dev_loss_tmo value.
              The Linux kernel will cap this value to 600 if fast_io_fail_tmo
              is not set.
            '';

            type = nullOr str;
          };

          failback = mkOption {
            default = null; # real default: "manual"
            description = "Tell multipathd how to manage path group failback. Quote integers as strings";
            type = nullOr str;
          };

          fast_io_fail_tmo = mkOption {
            default = null; # real default: 5

            description = ''
              Specify the number of seconds the SCSI layer will wait after a problem has been
              detected on a FC remote port before failing I/O to devices on that remote port.
              This should be smaller than dev_loss_tmo. Setting this to "off" will disable
              the timeout. Quote integers as strings.
            '';

            type = nullOr str;
          };

          features = mkOption {
            default = null;
            description = "Specify any device-mapper features to be used";
            type = nullOr str;
          };

          flush_on_last_del = mkOption {
            default = null; # real default: "no"

            description = ''
              If set to "yes" multipathd will disable queueing when the last path to a
              device has been deleted.
            '';

            type = nullOr (enum [
              "yes"
              "no"
            ]);
          };

          getuid_callout = mkOption {
            default = null;

            description = ''
              (Superseded by uid_attribute) The default program and args to callout
              to obtain a unique path identifier. Should be specified with an absolute path.
            '';

            type = nullOr str;
          };

          ghost_delay = mkOption {
            default = null;
            description = "Sets the number of seconds that multipath will wait after creating a device with only ghost paths before marking it ready for use in systemd";
            type = nullOr int;
          };

          hardware_handler = mkOption {
            default = null;
            description = "The hardware handler to use for this device type";

            type = nullOr (enum [
              "emc"
              "rdac"
              "hp_sw"
              "alua"
              "ana"
            ]);
          };

          marginal_path_double_failed_time = mkOption {
            default = null;
            description = "One of the four parameters of supporting path check based on accounting IO error such as intermittent error";
            type = nullOr str;
          };

          marginal_path_err_rate_threshold = mkOption {
            default = null;
            description = "The error rate threshold as a permillage (1/1000)";
            type = nullOr int;
          };

          marginal_path_err_recheck_gap_time = mkOption {
            default = null;
            description = "One of the four parameters of supporting path check based on accounting IO error such as intermittent error";
            type = nullOr str;
          };

          marginal_path_err_sample_time = mkOption {
            default = null;
            description = "One of the four parameters of supporting path check based on accounting IO error such as intermittent error";
            type = nullOr int;
          };

          max_sectors_kb = mkOption {
            default = null;
            description = "Sets the max_sectors_kb device parameter on all path devices and the multipath device to the specified value";
            type = nullOr int;
          };

          no_path_retry = mkOption {
            default = null; # real default: "fail"
            description = "Specify what to do when all paths are down. Quote integers as strings";
            type = nullOr str;
          };

          path_checker = mkOption {
            default = "tur";
            description = "The default method used to determine the paths state";

            type = enum [
              "readsector0"
              "tur"
              "emc_clariion"
              "hp_sw"
              "rdac"
              "directio"
              "cciss_tur"
              "none"
            ];
          };

          # Optional arguments
          path_grouping_policy = mkOption {
            default = null; # real default: "failover"
            description = "The default path grouping policy to apply to unspecified multipaths";

            type = nullOr (enum [
              "failover"
              "multibus"
              "group_by_serial"
              "group_by_prio"
              "group_by_node_name"
            ]);
          };

          path_selector = mkOption {
            default = null; # real default: "service-time 0"
            description = "The default path selector algorithm to use; they are offered by the kernel multipath target";

            type = nullOr (enum [
              ''"round-robin 0"''
              ''"queue-length 0"''
              ''"service-time 0"''
              ''"historical-service-time 0"''
            ]);
          };

          prio = mkOption {
            default = null; # real default: "const"
            description = "The name of the path priority routine";

            type = nullOr (enum [
              "none"
              "const"
              "sysfs"
              "emc"
              "alua"
              "ontap"
              "rdac"
              "hp_sw"
              "hds"
              "random"
              "weightedpath"
              "path_latency"
              "ana"
              "datacore"
              "iet"
            ]);
          };

          prio_args = mkOption {
            default = null;
            description = "Arguments to pass to to the prio function";
            type = nullOr str;
          };

          product = mkOption {
            description = "Regular expression to match the product name";
            example = "Compellent Vol";
            type = str;
          };

          product_blacklist = mkOption {
            default = null;
            description = "Products with the given vendor matching this string are blacklisted";
            type = nullOr str;
          };

          revision = mkOption {
            default = null;
            description = "Regular expression to match the product revision";
            type = nullOr str;
          };

          rr_min_io = mkOption {
            default = null; # real default: 1000

            description = ''
              Number of I/O requests to route to a path before switching to the next in the
              same path group. This is only for Block I/O (BIO) based multipath and
              only apply to round-robin path_selector.
            '';

            type = nullOr int;
          };

          rr_min_io_rq = mkOption {
            default = null; # real default: 1

            description = ''
              Number of I/O requests to route to a path before switching to the next in the
              same path group. This is only for Request based multipath and
              only apply to round-robin path_selector.
            '';

            type = nullOr int;
          };

          rr_weight = mkOption {
            default = null; # real default: "uniform"

            description = ''
              If set to priorities the multipath configurator will assign path weights
              as "path prio * rr_min_io".
            '';

            type = nullOr (enum [
              "priorities"
              "uniform"
            ]);
          };

          san_path_err_forget_rate = mkOption {
            default = null;

            description = ''
              If set to a value greater than 0, multipathd will check whether the path
              failures has exceeded the san_path_err_threshold within this many checks
              i.e san_path_err_forget_rate. If so we will not reinstante the path till
              san_path_err_recovery_time.
            '';

            type = nullOr str;
          };

          san_path_err_recovery_time = mkOption {
            default = null;

            description = ''
              If set to a value greater than 0, multipathd will make sure that when
              path failures has exceeded the san_path_err_threshold within
              san_path_err_forget_rate then the path will be placed in failed state
              for san_path_err_recovery_time duration. Once san_path_err_recovery_time
              has timeout we will reinstante the failed path. san_path_err_recovery_time
              value should be in secs.
            '';

            type = nullOr str;
          };

          san_path_err_threshold = mkOption {
            default = null;

            description = ''
              If set to a value greater than 0, multipathd will watch paths and check
              how many times a path has been failed due to errors.If the number of
              failures on a particular path is greater then the san_path_err_threshold,
              then the path will not reinstate till san_path_err_recovery_time. These
              path failures should occur within a san_path_err_forget_rate checks, if
              not we will consider the path is good enough to reinstantate.
            '';

            type = nullOr str;
          };

          skip_kpartx = mkOption {
            default = null; # real default: "no"
            description = "If set to yes, kpartx will not automatically create partitions on the device";

            type = nullOr (enum [
              "yes"
              "no"
            ]);
          };

          uid_attribute = mkOption {
            default = null;
            description = "The udev attribute providing a unique path identifier (WWID)";
            type = nullOr str;
          };

          user_friendly_names = mkOption {
            default = null; # real default: "no"

            description = ''
              If set to "yes", using the bindings file /etc/multipath/bindings
              to assign a persistent and unique alias to the multipath, in the
              form of mpath. If set to "no" use the WWID as the alias. In either
              case this be will be overridden by any specific aliases in the
              multipaths section.
            '';

            type = nullOr (enum [
              "yes"
              "no"
            ]);
          };

          vendor = mkOption {
            description = "Regular expression to match the vendor name";
            example = "COMPELNT";
            type = str;
          };

          vpd_vendor = mkOption {
            default = null;
            description = "The vendor specific vpd page information, using the vpd page abbreviation";
            type = nullOr str;
          };

        };
      });
    };

    extraConfig = mkOption {
      default = null;
      description = "Lines to append to default multipath.conf";
      type = nullOr str;
    };

    extraConfigFile = mkOption {
      default = null;
      description = "Append an additional file's contents to /etc/multipath.conf";
      type = nullOr str;
    };

    overrides = mkOption {
      default = null;

      description = ''
        This section defines values for attributes that should override the
        device-specific settings for all devices.
      '';

      type = nullOr str;
    };

    pathGroups = mkOption {
      description = ''
        This option allows you to define multipath groups as described
        in http://christophe.varoqui.free.fr/usage.html.
      '';

      example = literalExpression ''
        [
          {
            wwid = "360080e500043b35c0123456789abcdef";
            alias = 10001234;
            array = "bigarray.example.com";
            fsType = "zfs"; # optional
            options = "ro"; # optional
          }, ...
        ]
      '';

      type = listOf (submodule {
        options = {

          options = mkOption {
            default = null;
            description = "Options used to mount the file system";
            example = "ro";
            type = nullOr str;
          };

          alias = mkOption {
            description = "The name of the multipath device";
            example = 1001234;
            type = int;
          };

          array = mkOption {
            default = null;
            description = "The DNS name of the storage array";
            example = "bigarray.example.com";
            type = str;
          };

          fsType = mkOption {
            default = null;
            description = "Type of the filesystem";
            example = "zfs";
            type = nullOr str;
          };

          wwid = mkOption {
            description = "The identifier for the multipath device";
            example = "360080e500043b35c0123456789abcdef";
            type = hexStr;
          };

        };
      });
    };

  };

  config = mkIf cfg.enable {
    # We do not have systemd in stage-1 boot so must invoke `multipathd`
    # with the `-1` argument which disables systemd calls. Invoke `multipath`
    # to display the multipath mappings in the output of `journalctl -b`.
    # TODO: Implement for systemd stage 1
    boot.initrd.kernelModules = [
      "dm-multipath"
      "dm-service-time"
    ];

    boot.initrd.postDeviceCommands = mkIf (!config.boot.initrd.systemd.enable) ''
      modprobe -a dm-multipath dm-service-time
      multipathd -s
      (set -x && sleep 1 && multipath -ll)
    '';

    boot.kernelModules = [
      "dm-multipath"
      "dm-service-time"
    ];

    environment.etc."multipath.conf".text =
      let
        inherit (cfg)
          defaults
          blacklist
          blacklist_exceptions
          overrides
          ;

        mkDeviceBlock =
          cfg:
          let
            nonNullCfg = lib.filterAttrs (k: v: v != null) cfg;
            attrs = lib.mapAttrsToList (name: value: "  ${name} ${toString value}") nonNullCfg;
          in
          ''
            device {
            ${lib.concatStringsSep "\n" attrs}
            }
          '';
        devices = lib.concatMapStringsSep "\n" mkDeviceBlock cfg.devices;

        mkMultipathBlock = m: ''
          multipath {
            wwid ${m.wwid}
            alias ${toString m.alias}
          }
        '';
        multipaths = lib.concatMapStringsSep "\n" mkMultipathBlock cfg.pathGroups;

      in
      ''
        devices {
        ${indentLines 2 devices}
        }

        ${optionalString (defaults != null) ''
          defaults {
          ${indentLines 2 defaults}
          }
        ''}
        ${optionalString (blacklist != null) ''
          blacklist {
          ${indentLines 2 blacklist}
          }
        ''}
        ${optionalString (blacklist_exceptions != null) ''
          blacklist_exceptions {
          ${indentLines 2 blacklist_exceptions}
          }
        ''}
        ${optionalString (overrides != null) ''
          overrides {
          ${indentLines 2 overrides}
          }
        ''}
        multipaths {
        ${indentLines 2 multipaths}
        }
      '';

    environment.systemPackages = [ cfg.package ];
    systemd.packages = [ cfg.package ];
  };
}
