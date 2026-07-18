{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.pcscd;
  cfgFile = pkgs.writeText "reader.conf" (
    builtins.concatStringsSep "\n\n" config.services.pcscd.readerConfigs
  );

  pluginEnv = pkgs.buildEnv {
    name = "pcscd-plugins";
    paths = map (p: "${p}/pcsc/drivers") config.services.pcscd.plugins;
  };

in
{
  imports = [
    (lib.mkChangedOptionModule
      [ "services" "pcscd" "readerConfig" ]
      [ "services" "pcscd" "readerConfigs" ]
      (
        config:
        let
          readerConfig = lib.getAttrFromPath [ "services" "pcscd" "readerConfig" ] config;
        in
        [ readerConfig ]
      )
    )
  ];

  options.services.pcscd = {
    enable = lib.mkEnableOption "PCSC-Lite daemon, to access smart cards using SCard API (PC/SC)";

    package = (lib.mkPackageOption pkgs "pcsclite" { }) // {
      default = if config.security.polkit.enable then pkgs.pcscliteWithPolkit else pkgs.pcsclite;
      defaultText = lib.literalExpression "if config.security.polkit.enable then pkgs.pcscliteWithPolkit else pkgs.pcsclite";
    };

    extendReaderNames = lib.mkOption {
      default = null;

      description = ''
        String to append to every reader name. The special variable `$HOSTNAME`
        will be expanded to the current host name.
      '';

      example = " $HOSTNAME";
      type = lib.types.nullOr lib.types.str;
    };

    extraArgs = lib.mkOption {
      default = [ ];
      description = "Extra command line arguments to be passed to the PCSC daemon.";
      type = lib.types.listOf lib.types.str;
    };

    ignoreReaderNames = lib.mkOption {
      default = [ ];

      description = ''
        List of reader name patterns for the PCSC daemon to ignore.

        For more precise control, readers can be ignored through udev rules
        (cf. {option}`services.udev.extraRules`) by setting the
        `PCSCLITE_IGNORE` property, for example:

        ```
        ACTION!="remove|unbind", SUBSYSTEM=="usb", ATTR{idVendor}=="20a0", ENV{PCSCLITE_IGNORE}="1"
        ```
      '';

      example = [
        "Nitrokey"
        "YubiKey"
      ];

      type = lib.types.listOf (lib.types.strMatching "[^:]+");
    };

    plugins = lib.mkOption {
      defaultText = lib.literalExpression "[ pkgs.ccid ]";
      description = "Plugin packages to be used for PCSC-Lite.";
      example = lib.literalExpression "[ pkgs.pcsc-cyberjack ]";
      type = lib.types.listOf lib.types.package;
    };

    readerConfigs = lib.mkOption {
      default = [ ];

      description = ''
        Configuration for devices that aren't hotpluggable.

        See {manpage}`reader.conf(5)` for valid options.
      '';

      example = [
        ''
          FRIENDLYNAME      "Some serial reader"
          DEVICENAME        /dev/ttyS0
          LIBPATH           /path/to/serial_reader.so
          CHANNELID         1
        ''
      ];

      type = lib.types.listOf lib.types.lines;
    };
  };

  config = lib.mkIf config.services.pcscd.enable {
    environment.etc."reader.conf".source = cfgFile;
    environment.systemPackages = [ cfg.package ];
    services.pcscd.plugins = [ pkgs.ccid ];
    services.udev.packages = [ pkgs.ccid ];
    systemd.packages = [ cfg.package ];

    systemd.services.pcscd = {
      environment = {
        PCSCLITE_FILTER_EXTEND_READER_NAMES = lib.mkIf (
          cfg.extendReaderNames != null
        ) cfg.extendReaderNames;

        PCSCLITE_FILTER_IGNORE_READER_NAMES = lib.mkIf (cfg.ignoreReaderNames != [ ]) (
          lib.concatStringsSep ":" cfg.ignoreReaderNames
        );

        PCSCLITE_HP_DROPDIR = pluginEnv;
      };

      # If the cfgFile is empty and not specified (in which case the default
      # /etc/reader.conf is assumed), pcscd will happily start going through the
      # entire confdir (/etc in our case) looking for a config file and try to
      # parse everything it finds. Doesn't take a lot of imagination to see how
      # well that works. It really shouldn't do that to begin with, but to work
      # around it, we force the path to the cfgFile.
      #
      # https://github.com/NixOS/nixpkgs/issues/121088
      serviceConfig.ExecStart = [
        ""
        "${lib.getExe cfg.package} -f -x -c ${cfgFile} ${lib.escapeShellArgs cfg.extraArgs}"
      ];
    };

    systemd.sockets.pcscd.wantedBy = [ "sockets.target" ];
    users.groups.pcscd = { };

    users.users.pcscd = {
      group = "pcscd";
      isSystemUser = true;
    };
  };
}
