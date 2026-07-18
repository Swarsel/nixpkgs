{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.services.prometheus.exporters.restic;
  inherit (lib)
    mkOption
    types
    concatStringsSep
    mkIf
    mapAttrs'
    splitString
    toUpper
    optional
    optionalAttrs
    nameValuePair
    ;
in
{
  extraOpts = {
    environmentFile = mkOption {
      default = null;

      description = ''
        File containing the credentials to access the repository, in the
        format of an EnvironmentFile as described by {manpage}`systemd.exec(5)`
      '';

      type = with types; nullOr path;
    };

    passwordFile = mkOption {
      description = ''
        File containing the password to the repository.
      '';

      example = "/etc/nixos/restic-password";
      type = types.path;
    };

    rcloneConfig = mkOption {
      default = { };

      description = ''
        Configuration for the rclone remote being used for backup.
        See the remote's specific options under rclone's docs at
        <https://rclone.org/docs/>. When specifying
        option names, use the "config" name specified in the docs.
        For example, to set `--b2-hard-delete` for a B2
        remote, use `hard_delete = true` in the
        attribute set.

        ::: {.warning}
        Secrets set in here will be world-readable in the Nix
        store! Consider using the {option}`rcloneConfigFile`
        option instead to specify secret values separately. Note that
        options set here will override those set in the config file.
        :::
      '';

      type =
        with types;
        attrsOf (oneOf [
          str
          bool
        ]);
    };

    rcloneConfigFile = mkOption {
      default = null;

      description = ''
        Path to the file containing rclone configuration. This file
        must contain configuration for the remote specified in this backup
        set and also must be readable by root.

        ::: {.caution}
        Options set in `rcloneConfig` will override those set in this
        file.
        :::
      '';

      type = with types; nullOr path;
    };

    rcloneOptions = mkOption {
      default = { };

      description = ''
        Options to pass to rclone to control its behavior.
        See <https://rclone.org/docs/#options> for
        available options. When specifying option names, strip the
        leading `--`. To set a flag such as
        `--drive-use-trash`, which does not take a value,
        set the value to the Boolean `true`.
      '';

      type =
        with types;
        attrsOf (oneOf [
          str
          bool
        ]);
    };

    refreshInterval = mkOption {
      default = 60;

      description = ''
        Refresh interval for the metrics in seconds.
        Computing the metrics is an expensive task, keep this value as high as possible.
      '';

      type = types.ints.unsigned;
    };

    repository = mkOption {
      default = null;

      description = ''
        URI pointing to the repository to monitor.
      '';

      example = "sftp:backup@192.168.1.100:/backups/example";
      type = with lib.types; nullOr str;
    };

    repositoryFile = mkOption {
      default = null;

      description = ''
        Path to the file containing the URI for the repository to monitor.
      '';

      type = with lib.types; nullOr path;
    };
  };

  port = 9753;

  serviceOpts = {
    environment =
      let
        rcloneRemoteName = builtins.elemAt (splitString ":" cfg.repository) 1;
        rcloneAttrToOpt = v: "RCLONE_" + toUpper (builtins.replaceStrings [ "-" ] [ "_" ] v);
        rcloneAttrToConf = v: "RCLONE_CONFIG_" + toUpper (rcloneRemoteName + "_" + v);
        toRcloneVal = v: if lib.isBool v then lib.boolToString v else v;
      in
      {
        LISTEN_ADDRESS = cfg.listenAddress;
        LISTEN_PORT = toString cfg.port;
        REFRESH_INTERVAL = toString cfg.refreshInterval;
        RESTIC_CACHE_DIR = "$CACHE_DIRECTORY";
      }
      // (mapAttrs' (
        name: value: nameValuePair (rcloneAttrToOpt name) (toRcloneVal value)
      ) cfg.rcloneOptions)
      // optionalAttrs (cfg.rcloneConfigFile != null) {
        RCLONE_CONFIG = cfg.rcloneConfigFile;
      }
      // (mapAttrs' (
        name: value: nameValuePair (rcloneAttrToConf name) (toRcloneVal value)
      ) cfg.rcloneConfig);

    script = ''
      export RESTIC_REPOSITORY=${
        if cfg.repositoryFile != null then
          "$(cat $CREDENTIALS_DIRECTORY/RESTIC_REPOSITORY)"
        else
          "${cfg.repository}"
      }
      export RESTIC_PASSWORD_FILE=$CREDENTIALS_DIRECTORY/RESTIC_PASSWORD_FILE
      ${pkgs.prometheus-restic-exporter}/bin/restic-exporter.py \
        ${concatStringsSep " \\\n  " cfg.extraFlags}
    '';

    serviceConfig = {
      CacheDirectory = "restic-exporter";
      EnvironmentFile = mkIf (cfg.environmentFile != null) cfg.environmentFile;

      LoadCredential = [
        "RESTIC_PASSWORD_FILE:${cfg.passwordFile}"
      ]
      ++ optional (cfg.repositoryFile != null) [ "RESTIC_REPOSITORY:${cfg.repositoryFile}" ];
    };
  };
}
