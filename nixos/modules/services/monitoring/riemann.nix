{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.riemann;

  classpath = lib.concatStringsSep ":" (
    cfg.extraClasspathEntries ++ [ "${pkgs.riemann}/share/java/riemann.jar" ]
  );

  riemannConfig = lib.concatStringsSep "\n" (
    [ cfg.config ] ++ (map (f: ''(load-file "${f}")'') cfg.configFiles)
  );

  launcher = pkgs.writeScriptBin "riemann" ''
    #!/bin/sh
    exec ${pkgs.jdk}/bin/java ${lib.concatStringsSep " " cfg.extraJavaOpts} \
      -cp ${classpath} \
      riemann.bin ${cfg.configFile}
  '';

in
{

  options = {

    services.riemann = {
      config = lib.mkOption {
        description = ''
          Contents of the Riemann configuration file. For more complicated
          config you should use configFile.
        '';

        type = lib.types.lines;
      };

      enable = lib.mkEnableOption "Riemann network monitoring daemon";

      configFile = lib.mkOption {
        description = ''
          A Riemann config file. Any files in the same directory as this file
          will be added to the classpath by Riemann.
        '';

        type = lib.types.str;
      };

      configFiles = lib.mkOption {
        default = [ ];

        description = ''
          Extra files containing Riemann configuration. These files will be
          loaded at runtime by Riemann (with Clojure's
          `load-file` function) at the end of the
          configuration if you use the config option, this is ignored if you
          use configFile.
        '';

        type = with lib.types; listOf path;
      };

      extraClasspathEntries = lib.mkOption {
        default = [ ];

        description = ''
          Extra entries added to the Java classpath when running Riemann.
        '';

        type = with lib.types; listOf str;
      };

      extraJavaOpts = lib.mkOption {
        default = [ ];

        description = ''
          Extra Java options used when launching Riemann.
        '';

        type = with lib.types; listOf str;
      };
    };
  };

  config = lib.mkIf cfg.enable {

    services.riemann.configFile = lib.mkDefault (pkgs.writeText "riemann-config.clj" riemannConfig);

    systemd.services.riemann = {
      path = [ pkgs.inetutils ];

      serviceConfig = {
        ExecStart = "${launcher}/bin/riemann";
        User = "riemann";
      };

      serviceConfig.LimitNOFILE = 65536;
      wantedBy = [ "multi-user.target" ];
    };

    users.groups.riemann.gid = config.ids.gids.riemann;

    users.users.riemann = {
      description = "riemann daemon user";
      group = "riemann";
      uid = config.ids.uids.riemann;
    };

  };

}
