{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  logPrefix = "services.prometheus.exporter.blackbox";
  cfg = config.services.prometheus.exporters.blackbox;
  inherit (lib)
    mkOption
    types
    concatStringsSep
    escapeShellArg
    ;

  # This ensures that we can deal with string paths, path types and
  # store-path strings with context.
  coerceConfigFile =
    file:
    if (builtins.isPath file) || (lib.isStorePath file) then
      file
    else
      (lib.warn ''
        ${logPrefix}: configuration file "${file}" is being copied to the nix-store.
        If you would like to avoid that, please set enableConfigCheck to false.
      '' (builtins.toFile (builtins.baseNameOf file) (builtins.readFile file)));
  checkConfigLocation =
    file:
    if lib.hasPrefix "/tmp/" file then
      throw "${logPrefix}: configuration file must not reside within /tmp - it won't be visible to the systemd service."
    else
      file;
  checkConfig =
    file:
    pkgs.runCommand "checked-blackbox-exporter.conf"
      {
        nativeBuildInputs = [ pkgs.buildPackages.prometheus-blackbox-exporter ];
        preferLocalBuild = true;
      }
      ''
        ln -s ${coerceConfigFile file} $out
        blackbox_exporter --config.check --config.file $out
      '';
in
{
  extraOpts = {
    configFile = mkOption {
      description = ''
        Path to configuration file.
      '';

      type = types.path;
    };

    enableConfigCheck = mkOption {
      default = true;

      description = ''
        Whether to run a correctness check for the configuration file. This depends
        on the configuration file residing in the nix-store. Paths passed as string will
        be copied to the store.
      '';

      type = types.bool;
    };
  };

  port = 9115;

  serviceOpts =
    let
      adjustedConfigFile =
        if cfg.enableConfigCheck then checkConfig cfg.configFile else checkConfigLocation cfg.configFile;
    in
    {
      serviceConfig = {
        AmbientCapabilities = [ "CAP_NET_RAW" ]; # for ping probes
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";

        ExecStart = ''
          ${pkgs.prometheus-blackbox-exporter}/bin/blackbox_exporter \
            --web.listen-address ${cfg.listenAddress}:${toString cfg.port} \
            --config.file ${escapeShellArg adjustedConfigFile} \
            ${concatStringsSep " \\\n  " cfg.extraFlags}
        '';
      };
    };
}
