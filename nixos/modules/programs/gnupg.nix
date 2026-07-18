{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkRemovedOptionModule
    mkOption
    mkPackageOption
    types
    mkIf
    optionalString
    ;

  cfg = config.programs.gnupg;

  agentSettingsFormat = pkgs.formats.keyValue {
    mkKeyValue = lib.generators.mkKeyValueDefault { } " ";
  };
in
{
  imports = [
    (mkRemovedOptionModule [
      "programs"
      "gnupg"
      "agent"
      "pinentryFlavor"
    ] "Use programs.gnupg.agent.pinentryPackage instead")
  ];

  options.programs.gnupg = {
    package = mkPackageOption pkgs "gnupg" { };

    agent.enable = mkOption {
      default = false;

      description = ''
        Enables GnuPG agent with socket-activation for every user session.
      '';

      type = types.bool;
    };

    agent.enableBrowserSocket = mkOption {
      default = false;

      description = ''
        Enable browser socket for GnuPG agent.
      '';

      type = types.bool;
    };

    agent.enableExtraSocket = mkOption {
      default = false;

      description = ''
        Enable extra socket for GnuPG agent.
      '';

      type = types.bool;
    };

    agent.enableSSHSupport = mkOption {
      default = false;

      description = ''
        Enable SSH agent support in GnuPG agent. Also sets SSH_AUTH_SOCK
        environment variable correctly. This will disable socket-activation
        and thus always start a GnuPG agent per user session.
      '';

      type = types.bool;
    };

    agent.pinentryPackage = mkOption {
      default = pkgs.pinentry-curses;
      defaultText = lib.literalMD "matching the configured desktop environment or `pkgs.pinentry-curses`";

      description = ''
        Which pinentry package to use. The path to the mainProgram as defined in
        the package's meta attributes will be set in /etc/gnupg/gpg-agent.conf.
        If not set by the user, it'll pick an appropriate flavor depending on the
        system configuration (qt flavor for lxqt and plasma, gtk2 for xfce,
        gnome3 on all other systems with X enabled, curses otherwise).
      '';

      example = lib.literalMD "pkgs.pinentry-gnome3";
      type = types.nullOr types.package;
    };

    agent.settings = mkOption {
      default = { };

      description = ''
        Configuration for /etc/gnupg/gpg-agent.conf.
        See {manpage}`gpg-agent(1)` for supported options.
      '';

      example = {
        default-cache-ttl = 600;
      };

      type = agentSettingsFormat.type;
    };

    dirmngr.enable = mkOption {
      default = false;

      description = ''
        Enables GnuPG network certificate management daemon with socket-activation for every user session.
      '';

      type = types.bool;
    };
  };

  config = mkIf cfg.agent.enable {
    assertions = [
      {
        assertion = cfg.agent.enableSSHSupport -> !config.programs.ssh.startAgent;
        message = "You can't use ssh-agent and GnuPG agent with SSH support enabled at the same time!";
      }
    ];

    environment.etc."gnupg/gpg-agent.conf".source =
      agentSettingsFormat.generate "gpg-agent.conf" cfg.agent.settings;

    environment.extraInit = mkIf cfg.agent.enableSSHSupport ''
      if [ -z "$SSH_AUTH_SOCK" ]; then
        export SSH_AUTH_SOCK=$(${cfg.package}/bin/gpgconf --list-dirs agent-ssh-socket)
      fi
    '';

    environment.interactiveShellInit = ''
      # Bind gpg-agent to this TTY if gpg commands are used.
      export GPG_TTY=$(tty)
    '';

    environment.systemPackages = [ cfg.package ];

    programs.gnupg.agent.settings = mkIf (cfg.agent.pinentryPackage != null) {
      pinentry-program = lib.getExe cfg.agent.pinentryPackage;
    };

    programs.ssh.extraConfig = optionalString cfg.agent.enableSSHSupport ''
      # The SSH agent protocol doesn't have support for changing TTYs; however we
      # can simulate this with the `exec` feature of openssh (see ssh_config(5))
      # that hooks a command to the shell currently running the ssh program.
      Match host * exec "${pkgs.runtimeShell} -c '${cfg.package}/bin/gpg-connect-agent --quiet updatestartuptty /bye >/dev/null 2>&1'"
    '';

    services.dbus.packages = mkIf (lib.elem "gnome3" (cfg.agent.pinentryPackage.flavors or [ ])) [
      pkgs.gcr
    ];

    systemd.user.services.dirmngr = mkIf cfg.dirmngr.enable {
      serviceConfig = {
        ExecReload = "${cfg.package}/bin/gpgconf --reload dirmngr";
        ExecStart = "${cfg.package}/bin/dirmngr --supervised";
      };

      unitConfig = {
        Description = "GnuPG network certificate management daemon";
        Documentation = "man:dirmngr(8)";
        Requires = "dirmngr.socket";
      };
    };

    # This overrides the systemd user unit shipped with the gnupg package
    systemd.user.services.gpg-agent = {
      serviceConfig = {
        ExecReload = "${cfg.package}/bin/gpgconf --reload gpg-agent";
        ExecStart = "${cfg.package}/bin/gpg-agent --supervised";
      };

      unitConfig = {
        Description = "GnuPG cryptographic agent and passphrase cache";
        Documentation = "man:gpg-agent(1)";
        Requires = [ "sockets.target" ];
      };
    };

    systemd.user.sockets.dirmngr = mkIf cfg.dirmngr.enable {
      socketConfig = {
        DirectoryMode = "0700";
        ListenStream = "%t/gnupg/S.dirmngr";
        SocketMode = "0600";
      };

      unitConfig = {
        Description = "GnuPG network certificate management daemon";
        Documentation = "man:dirmngr(8)";
      };

      wantedBy = [ "sockets.target" ];
    };

    systemd.user.sockets.gpg-agent = {
      socketConfig = {
        DirectoryMode = "0700";
        FileDescriptorName = "std";
        ListenStream = "%t/gnupg/S.gpg-agent";
        SocketMode = "0600";
      };

      unitConfig = {
        Description = "GnuPG cryptographic agent and passphrase cache";
        Documentation = "man:gpg-agent(1)";
      };

      wantedBy = [ "sockets.target" ];
    };

    systemd.user.sockets.gpg-agent-browser = mkIf cfg.agent.enableBrowserSocket {
      socketConfig = {
        DirectoryMode = "0700";
        FileDescriptorName = "browser";
        ListenStream = "%t/gnupg/S.gpg-agent.browser";
        Service = "gpg-agent.service";
        SocketMode = "0600";
      };

      unitConfig = {
        Description = "GnuPG cryptographic agent and passphrase cache (access for web browsers)";
        Documentation = "man:gpg-agent(1)";
      };

      wantedBy = [ "sockets.target" ];
    };

    systemd.user.sockets.gpg-agent-extra = mkIf cfg.agent.enableExtraSocket {
      socketConfig = {
        DirectoryMode = "0700";
        FileDescriptorName = "extra";
        ListenStream = "%t/gnupg/S.gpg-agent.extra";
        Service = "gpg-agent.service";
        SocketMode = "0600";
      };

      unitConfig = {
        Description = "GnuPG cryptographic agent and passphrase cache (restricted)";
        Documentation = "man:gpg-agent(1)";
      };

      wantedBy = [ "sockets.target" ];
    };

    systemd.user.sockets.gpg-agent-ssh = mkIf cfg.agent.enableSSHSupport {
      socketConfig = {
        DirectoryMode = "0700";
        FileDescriptorName = "ssh";
        ListenStream = "%t/gnupg/S.gpg-agent.ssh";
        Service = "gpg-agent.service";
        SocketMode = "0600";
      };

      unitConfig = {
        Description = "GnuPG cryptographic agent (ssh-agent emulation)";
        Documentation = "man:gpg-agent(1) man:ssh-add(1) man:ssh-agent(1) man:ssh(1)";
      };

      wantedBy = [ "sockets.target" ];
    };
  };
}
