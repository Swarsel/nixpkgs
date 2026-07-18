{
  config,
  lib,
  pkgs,
  ...
}:
let

  concatMapLines = f: l: lib.concatStringsSep "\n" (map f l);

  cfg = config.services.mlmmj;
  stateDir = "/var/lib/mlmmj";
  spoolDir = "/var/spool/mlmmj";
  listDir = domain: list: "${spoolDir}/${domain}/${list}";
  listCtl = domain: list: "${listDir domain list}/control";
  transport = domain: list: "${domain}--${list}@local.list.mlmmj mlmmj:${domain}/${list}";
  virtual = domain: list: "${list}@${domain} ${domain}--${list}@local.list.mlmmj";
  alias = domain: list: "${list}: \"|${pkgs.mlmmj}/bin/mlmmj-receive -L ${listDir domain list}/\"";
  subjectPrefix = list: "[${list}]";
  listAddress = domain: list: "${list}@${domain}";
  customHeaders = domain: list: [
    "List-Id: ${list}"
    "Reply-To: ${list}@${domain}"
    "List-Post: <mailto:${list}@${domain}>"
    "List-Help: <mailto:${list}+help@${domain}>"
    "List-Subscribe: <mailto:${list}+subscribe@${domain}>"
    "List-Unsubscribe: <mailto:${list}+unsubscribe@${domain}>"
  ];
  footer = domain: list: "To unsubscribe send a mail to ${list}+unsubscribe@${domain}";
  createList =
    d: l:
    let
      ctlDir = listCtl d l;
    in
    ''
      for DIR in incoming queue queue/discarded archive text subconf unsubconf \
                 bounce control moderation subscribers.d digesters.d requeue \
                 nomailsubs.d
      do
             mkdir -p '${listDir d l}'/"$DIR"
      done
      ${pkgs.coreutils}/bin/mkdir -p ${ctlDir}
      echo ${listAddress d l} > '${ctlDir}/listaddress'
      [ ! -e ${ctlDir}/customheaders ] && \
          echo "${lib.concatStringsSep "\n" (customHeaders d l)}" > '${ctlDir}/customheaders'
      [ ! -e ${ctlDir}/footer ] && \
          echo ${footer d l} > '${ctlDir}/footer'
      [ ! -e ${ctlDir}/prefix ] && \
          echo ${subjectPrefix l} > '${ctlDir}/prefix'
    '';
in

{

  ###### interface

  options = {

    services.mlmmj = {

      enable = lib.mkOption {
        default = false;
        description = "Enable mlmmj";
        type = lib.types.bool;
      };

      group = lib.mkOption {
        default = "mlmmj";
        description = "mailinglist local group";
        type = lib.types.str;
      };

      listDomain = lib.mkOption {
        default = "localhost";
        description = "Set the mailing list domain";
        type = lib.types.str;
      };

      mailLists = lib.mkOption {
        default = [ ];
        description = "The collection of hosted maillists";
        type = lib.types.listOf lib.types.str;
      };

      maintInterval = lib.mkOption {
        default = "20min";

        description = ''
          Time interval between mlmmj-maintd runs, see
          {manpage}`systemd.time(7)` for format information.
        '';

        type = lib.types.str;
      };

      user = lib.mkOption {
        default = "mlmmj";
        description = "mailinglist local user";
        type = lib.types.str;
      };

    };

  };

  ###### implementation

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ pkgs.mlmmj ];

    services.postfix = {
      enable = true;
      extraAliases = concatMapLines (alias cfg.listDomain) cfg.mailLists;

      settings.main = {
        propagate_unmatched_extensions = "virtual";
        recipient_delimiter = "+";
      };

      settings.master.mlmmj = {
        args = [
          "flags=ORhu"
          "user=mlmmj"
          "argv=${pkgs.mlmmj}/bin/mlmmj-receive"
          "-F"
          "-L"
          "${spoolDir}/$nexthop"
        ];

        chroot = false;
        command = "pipe";
        private = true;
        privileged = true;
        type = "unix";
        wakeup = 0;
      };

      transport = concatMapLines (transport cfg.listDomain) cfg.mailLists;
      virtual = concatMapLines (virtual cfg.listDomain) cfg.mailLists;
    };

    systemd.services.mlmmj-maintd = {
      description = "mlmmj maintenance daemon";

      preStart = ''
        ${concatMapLines (createList cfg.listDomain) cfg.mailLists}
        ${lib.getExe' config.services.postfix.package "postmap"} /etc/postfix/virtual
        ${lib.getExe' config.services.postfix.package "postmap"} /etc/postfix/transport
      '';

      serviceConfig = {
        ExecStart = "${pkgs.mlmmj}/bin/mlmmj-maintd -F -d ${spoolDir}/${cfg.listDomain}";
        Group = cfg.group;
        User = cfg.user;
      };
    };

    systemd.timers.mlmmj-maintd = {
      description = "mlmmj maintenance timer";
      timerConfig.OnUnitActiveSec = cfg.maintInterval;
      wantedBy = [ "timers.target" ];
    };

    systemd.tmpfiles.settings."10-mlmmj" = {
      ${spoolDir}.Z = {
        inherit (cfg) user group;
      };

      "${spoolDir}/${cfg.listDomain}".d = { };
      ${stateDir}.d = { };
    };

    users.groups.${cfg.group} = {
      gid = config.ids.gids.mlmmj;
    };

    users.users.${cfg.user} = {
      createHome = true;
      description = "mlmmj user";
      group = cfg.group;
      home = stateDir;
      uid = config.ids.uids.mlmmj;
      useDefaultShell = true;
    };
  };

}
