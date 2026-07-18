{
  config,
  lib,
  pkgs,
  ...
}:

let

  inherit (lib)
    concatLines
    escapeShellArgs
    mkIf
    mkMerge
    optional
    ;
  inherit (lib.cli) toCommandLine;

  optionFormat = optionName: {
    explicitBool = false;
    option = "-${optionName}";
    sep = null;
  };

  cfg = config.services.hylafax;
  mapModems = lib.forEach (lib.attrValues cfg.modems);

  mkSpoolCmd =
    prefix: program: posArg: options:
    let
      start = "${prefix}${cfg.package}/spool/bin/${program}";
      optionsList = toCommandLine optionFormat ({ q = cfg.spoolAreaPath; } // options);
      posArgList = optional (posArg != null) posArg;
    in
    "${start} ${escapeShellArgs (optionsList ++ posArgList)}";

  mkConfigFile =
    name: conf:
    # creates hylafax config file,
    # makes sure "Include" is listed *first*
    let
      mkLines = lib.flip lib.pipe [
        (lib.mapAttrsToList (key: map (val: "${key}: ${val}")))
        lib.concatLists
      ];
      include = mkLines { Include = conf.Include or [ ]; };
      other = mkLines (conf // { Include = [ ]; });
    in
    pkgs.writeText "hylafax-config${name}" (concatLines (include ++ other));

  globalConfigPath = mkConfigFile "" cfg.faxqConfig;

  modemConfigPath =
    let
      mkModemConfigFile =
        { config, name, ... }: mkConfigFile ".${name}" (cfg.commonModemConfig // config);
      mkLine =
        { name, type, ... }@modem:
        ''
          # check if modem config file exists:
          test -f "${cfg.package}/spool/config/${type}"
          ln \
            --symbolic \
            --no-target-directory \
            "${mkModemConfigFile modem}" \
            "$out/config.${name}"
        '';
    in
    pkgs.runCommand "hylafax-config-modems" {
      preferLocalBuild = true;
    } ''mkdir --parents "$out/" ${concatLines (mapModems mkLine)}'';

  setupSpoolScript = pkgs.replaceVarsWith {
    isExecutable = true;
    name = "hylafax-setup-spool.sh";

    replacements = {
      inherit globalConfigPath modemConfigPath;
      inherit (cfg) package spoolAreaPath userAccessFile;
      inherit (pkgs) runtimeShell;
      faxgroup = "uucp";
      faxuser = "uucp";
      lockPath = "/var/lock";
    };

    src = ./spool.sh;
  };

  waitFaxqScript = pkgs.replaceVarsWith {
    isExecutable = true;
    # This script checks the modems status files
    # and waits until all modems report readiness.
    name = "hylafax-faxq-wait-start.sh";

    replacements = {
      inherit (cfg) spoolAreaPath;
      inherit (pkgs) runtimeShell;
      timeoutSec = toString 10;
    };

    src = ./faxq-wait.sh;
  };

  sockets.hylafax-hfaxd = {
    description = "HylaFAX server socket";
    documentation = [ "man:hfaxd(8)" ];
    listenStreams = [ "127.0.0.1:4559" ];
    socketConfig.Accept = true;
    socketConfig.FreeBind = true;
    wantedBy = [ "multi-user.target" ];
  };

  paths.hylafax-faxq = {
    description = "HylaFAX queue manager sendq watch";

    documentation = [
      "man:faxq(8)"
      "man:sendq(5)"
    ];

    pathConfig.PathExistsGlob = [ "${cfg.spoolAreaPath}/sendq/q*" ];
    wantedBy = [ "multi-user.target" ];
  };

  timers = mkMerge [
    (mkIf (cfg.faxcron.enable.frequency != null) { hylafax-faxcron.timerConfig.Persistent = true; })
    (mkIf (cfg.faxqclean.enable.frequency != null) { hylafax-faxqclean.timerConfig.Persistent = true; })
  ];

  hardenService =
    # Add some common systemd service hardening settings,
    # but allow each service (here) to override
    # settings by explicitly setting those to `null`.
    # More hardening would be nice but makes
    # customizing hylafax setups very difficult.
    # If at all, it should only be added along
    # with some options to customize it.
    let
      hardening = {
        PrivateDevices = true; # breaks /dev/tty...
        PrivateNetwork = true;
        PrivateTmp = true;
        #ProtectClock = true;  # breaks /dev/tty... (why?)
        ProtectControlGroups = true;
        #ProtectHome = true;  # breaks custom spool dirs
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        #ProtectSystem = "strict";  # breaks custom spool dirs
        RestrictNamespaces = true;
        RestrictRealtime = true;
      };
      filter = key: value: (value != null) || !(lib.hasAttr key hardening);
      apply = service: lib.filterAttrs filter (hardening // (service.serviceConfig or { }));
    in
    service: service // { serviceConfig = apply service; };

  services.hylafax-spool = {
    description = "HylaFAX spool area preparation";
    documentation = [ "man:hylafax-server(4)" ];

    script = ''
      ${setupSpoolScript}
      cd "${cfg.spoolAreaPath}"
      ${cfg.spoolExtraInit}
      if ! test -f "${cfg.spoolAreaPath}/etc/hosts.hfaxd"
      then
        echo hosts.hfaxd is missing
        exit 1
      fi
    '';

    serviceConfig.ExecStop = "${setupSpoolScript}";
    serviceConfig.RemainAfterExit = true;
    serviceConfig.Type = "oneshot";
    unitConfig.RequiresMountsFor = [ cfg.spoolAreaPath ];
  };

  services.hylafax-faxq = {
    after = [ "hylafax-spool.service" ];
    description = "HylaFAX queue manager";
    documentation = [ "man:faxq(8)" ];
    requires = [ "hylafax-spool.service" ];
    serviceConfig.ExecStart = mkSpoolCmd "" "faxq" null { };
    # This delays the "readiness" of this service until
    # all modems are initialized (or a timeout is reached).
    # Otherwise, sending a fax with the fax service
    # stopped will always yield a failed send attempt:
    # The fax service is started when the job is created with
    # `sendfax`, but modems need some time to initialize.
    serviceConfig.ExecStartPost = [ "${waitFaxqScript}" ];
    # faxquit fails if the pipe is already gone
    # (e.g. the service is already stopping)
    serviceConfig.ExecStop = mkSpoolCmd "-" "faxquit" null { };
    # disable some systemd hardening settings
    serviceConfig.PrivateDevices = null;
    serviceConfig.RestrictRealtime = null;
    serviceConfig.Type = "forking";
    wantedBy = mkIf cfg.autostart [ "multi-user.target" ];
    wants = mapModems ({ name, ... }: "hylafax-faxgetty@${name}.service");
  };

  services."hylafax-hfaxd@" = {
    after = [ "hylafax-faxq.service" ];
    description = "HylaFAX server";
    documentation = [ "man:hfaxd(8)" ];
    requires = [ "hylafax-faxq.service" ];

    serviceConfig.ExecStart = mkSpoolCmd "" "hfaxd" null {
      I = true;
      d = true;
    };

    # disable some systemd hardening settings
    serviceConfig.PrivateDevices = null;
    serviceConfig.PrivateNetwork = null;
    serviceConfig.StandardInput = "socket";
    serviceConfig.StandardOutput = "socket";
    unitConfig.RequiresMountsFor = [ cfg.userAccessFile ];
  };

  services.hylafax-faxcron = rec {
    after = [ "hylafax-spool.service" ];
    description = "HylaFAX spool area maintenance";
    documentation = [ "man:faxcron(8)" ];
    requires = [ "hylafax-spool.service" ];

    serviceConfig.ExecStart = mkSpoolCmd "" "faxcron" null {
      info = cfg.faxcron.infoDays;
      log = cfg.faxcron.logDays;
      rcv = cfg.faxcron.rcvDays;
    };

    startAt = mkIf (cfg.faxcron.enable.frequency != null) cfg.faxcron.enable.frequency;
    wantedBy = mkIf cfg.faxcron.enable.spoolInit requires;
  };

  services.hylafax-faxqclean = rec {
    after = [ "hylafax-spool.service" ];
    description = "HylaFAX spool area queue cleaner";
    documentation = [ "man:faxqclean(8)" ];
    requires = [ "hylafax-spool.service" ];

    serviceConfig.ExecStart = mkSpoolCmd "" "faxqclean" null {
      A = cfg.faxqclean.archiving == "always";
      a = cfg.faxqclean.archiving != "never";
      d = 60 * cfg.faxqclean.docqMinutes;
      j = 60 * cfg.faxqclean.doneqMinutes;
      v = true;
    };

    startAt = mkIf (cfg.faxqclean.enable.frequency != null) cfg.faxqclean.enable.frequency;
    wantedBy = mkIf cfg.faxqclean.enable.spoolInit requires;
  };

  mkFaxgettyService =
    { name, ... }:
    lib.nameValuePair "hylafax-faxgetty@${name}" rec {
      after = bindsTo ++ requires;

      before = [
        "hylafax-faxq.service"
        "getty.target"
      ];

      bindsTo = [ "dev-%i.device" ];
      description = "HylaFAX faxgetty for %I";
      documentation = [ "man:faxgetty(8)" ];
      requires = [ "hylafax-spool.service" ];
      serviceConfig.ExecStart = mkSpoolCmd "-" "faxgetty" "/dev/%I" { };
      # faxquit fails if the pipe is already gone
      # (e.g. the service is already stopping)
      serviceConfig.ExecStop = mkSpoolCmd "-" "faxquit" "%I" { };
      serviceConfig.IgnoreSIGPIPE = false;
      serviceConfig.KillMode = "process";
      # disable some systemd hardening settings
      serviceConfig.PrivateDevices = null;
      serviceConfig.Restart = "always";
      serviceConfig.RestrictRealtime = null;
      serviceConfig.TTYPath = "/dev/%I";
      serviceConfig.UtmpIdentifier = "%I";
      unitConfig.AssertFileNotEmpty = "${cfg.spoolAreaPath}/etc/config.%I";
      unitConfig.StopWhenUnneeded = true;
    };

  modemServices = lib.listToAttrs (mapModems mkFaxgettyService);

in

{
  config.systemd = mkIf cfg.enable {
    inherit sockets timers paths;
    services = lib.mapAttrs (lib.const hardenService) (services // modemServices);
  };
}
