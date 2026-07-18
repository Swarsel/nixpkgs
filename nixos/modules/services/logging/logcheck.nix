{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.logcheck;

  defaultRules = pkgs.runCommand "logcheck-default-rules" { preferLocalBuild = true; } ''
    cp -prd ${pkgs.logcheck}/etc/logcheck $out
    chmod u+w $out
    rm -r $out/logcheck.*
  '';

  rulesDir = pkgs.symlinkJoin {
    name = "logcheck-rules-dir";
    paths = ([ defaultRules ] ++ cfg.extraRulesDirs);
  };

  configFile = pkgs.writeText "logcheck.conf" cfg.config;

  logFiles = pkgs.writeText "logcheck.logfiles" cfg.files;

  flags = "-r ${rulesDir} -c ${configFile} -L ${logFiles} -${levelFlag} -m ${cfg.mailTo}";

  levelFlag = lib.getAttrFromPath [ cfg.level ] {
    paranoid = "p";
    server = "s";
    workstation = "w";
  };

  cronJob = ''
    @reboot   logcheck env PATH=/run/wrappers/bin:$PATH nice -n10 ${pkgs.logcheck}/sbin/logcheck -R ${flags}
    2 ${cfg.timeOfDay} * * * logcheck env PATH=/run/wrappers/bin:$PATH nice -n10 ${pkgs.logcheck}/sbin/logcheck ${flags}
  '';

  writeIgnoreRule =
    name:
    { level, regex, ... }:
    pkgs.writeTextFile {
      inherit name;
      destination = "/ignore.d.${level}/${name}";

      text = ''
        ^\w{3} [ :[:digit:]]{11} [._[:alnum:]-]+ ${regex}
      '';
    };

  writeIgnoreCronRule =
    name:
    {
      cmdline,
      level,
      regex,
      user,
      ...
    }:
    let
      escapeRegex = lib.escape (lib.stringToCharacters "\\[]{}()^$?*+|.");
      cmdline_ = builtins.unsafeDiscardStringContext cmdline;
      re =
        if regex != "" then
          regex
        else if cmdline_ == "" then
          ".*"
        else
          escapeRegex cmdline_;
    in
    writeIgnoreRule "cron-${name}" {
      inherit level;

      regex = ''
        (/usr/bin/)?cron\[[0-9]+\]: \(${user}\) CMD \(${re}\)$
      '';
    };

  levelOption = lib.mkOption {
    default = "server";

    description = ''
      Set the logcheck level.
    '';

    type = lib.types.enum [
      "workstation"
      "server"
      "paranoid"
    ];
  };

  ignoreOptions = {
    options = {
      level = levelOption;

      regex = lib.mkOption {
        default = "";

        description = ''
          Regex specifying which log lines to ignore.
        '';

        type = lib.types.str;
      };
    };
  };

  ignoreCronOptions = {
    options = {
      cmdline = lib.mkOption {
        default = "";

        description = ''
          Command line for the cron job. Will be turned into a regex for the logcheck ignore rule.
        '';

        type = lib.types.str;
      };

      timeArgs = lib.mkOption {
        default = null;

        description = ''
          "min hr dom mon dow" crontab time args, to auto-create a cronjob too.
          Leave at null to not do this and just add a logcheck ignore rule.
        '';

        example = "02 06 * * *";
        type = lib.types.nullOr (lib.types.str);
      };

      user = lib.mkOption {
        default = "root";

        description = ''
          User that runs the cronjob.
        '';

        type = lib.types.str;
      };
    };
  };

in
{
  options = {
    services.logcheck = {
      config = lib.mkOption {
        default = "FQDN=1";

        description = ''
          Config options that you would like in logcheck.conf.
        '';

        type = lib.types.lines;
      };

      enable = lib.mkEnableOption "logcheck cron job, to mail anomalies in the system logfiles to the administrator";

      extraGroups = lib.mkOption {
        default = [ ];

        description = ''
          Extra groups for the logcheck user, for example to be able to use sendmail,
          or to access certain log files.
        '';

        example = [
          "postdrop"
          "mongodb"
        ];

        type = lib.types.listOf lib.types.str;
      };

      extraRulesDirs = lib.mkOption {
        default = [ ];

        description = ''
          Directories with extra rules.
        '';

        example = [ "/etc/logcheck" ];
        type = lib.types.listOf lib.types.path;
      };

      files = lib.mkOption {
        default = [ "/var/log/messages" ];

        description = ''
          Which log files to check.
        '';

        example = [
          "/var/log/messages"
          "/var/log/mail"
        ];

        type = lib.types.listOf lib.types.path;
      };

      ignore = lib.mkOption {
        default = { };

        description = ''
          This option defines extra ignore rules.
        '';

        type = with lib.types; attrsOf (submodule ignoreOptions);
      };

      ignoreCron = lib.mkOption {
        default = { };

        description = ''
          This option defines extra ignore rules for cronjobs.
        '';

        type = with lib.types; attrsOf (submodule ignoreCronOptions);
      };

      level = lib.mkOption {
        default = "server";

        description = ''
          Set the logcheck level. Either "workstation", "server", or "paranoid".
        '';

        type = lib.types.str;
      };

      mailTo = lib.mkOption {
        default = "root";

        description = ''
          Email address to send reports to.
        '';

        example = "you@domain.com";
        type = lib.types.str;
      };

      timeOfDay = lib.mkOption {
        default = "*";

        description = ''
          Time of day to run logcheck. A logcheck will be scheduled at xx:02 each day.
          Leave default (*) to run every hour. Of course when nothing special was logged,
          logcheck will be silent.
        '';

        example = "6";
        type = lib.types.str;
      };

      user = lib.mkOption {
        default = "logcheck";

        description = ''
          Username for the logcheck user.
        '';

        type = lib.types.str;
      };

    };
  };

  config = lib.mkIf cfg.enable {
    services.cron.systemCronJobs =
      let
        withTime = name: { timeArgs, ... }: timeArgs != null;
        mkCron =
          name:
          {
            cmdline,
            timeArgs,
            user,
            ...
          }:
          ''
            ${timeArgs} ${user} ${cmdline}
          '';
      in
      lib.mapAttrsToList mkCron (lib.filterAttrs withTime cfg.ignoreCron) ++ [ cronJob ];

    services.logcheck.extraRulesDirs =
      lib.mapAttrsToList writeIgnoreRule cfg.ignore
      ++ lib.mapAttrsToList writeIgnoreCronRule cfg.ignoreCron;

    systemd.tmpfiles.settings.logcheck = {
      "/var/lib/logcheck".d = {
        inherit (cfg) user;
        mode = "700";
      };

      "/var/lock/logcheck".d = {
        inherit (cfg) user;
        mode = "700";
      };
    };

    users.groups = lib.optionalAttrs (cfg.user == "logcheck") {
      logcheck = { };
    };

    users.users = lib.optionalAttrs (cfg.user == "logcheck") {
      logcheck = {
        description = "Logcheck user account";
        extraGroups = cfg.extraGroups;
        group = "logcheck";
        isSystemUser = true;
        shell = "/bin/sh";
      };
    };
  };
}
