{
  config,
  lib,
  pkgs,
  ...
}:
let

  # The splicing information needed for nativeBuildInputs isn't available
  # on the derivations likely to be used as `cfg.package`.
  # This middle-ground solution ensures *an* sshd can do their basic validation
  # on the configuration.
  validationPackage =
    if pkgs.stdenv.buildPlatform == pkgs.stdenv.hostPlatform then
      cfg.package
    else
      pkgs.buildPackages.openssh;

  # dont use the "=" operator
  settingsFormat =
    let
      # reports boolean as yes / no
      mkValueString =
        v:
        if lib.isInt v then
          toString v
        else if lib.isString v then
          v
        else if lib.isPath v then
          v
        else if true == v then
          "yes"
        else if false == v then
          "no"
        else
          throw "unsupported type ${builtins.typeOf v}: ${(lib.generators.toPretty { }) v}";

      base = pkgs.formats.keyValue {
        mkKeyValue = lib.generators.mkKeyValueDefault { inherit mkValueString; } " ";
      };
      # OpenSSH is very inconsistent with options that can take multiple values.
      # For some of them, they can simply appear multiple times and are appended, for others the
      # values must be separated by whitespace or even commas.
      # Consult either sshd_config(5) or, as last resort, the OpehSSH source for parsing
      # the options at servconf.c:process_server_config_line_depth() to determine the right "mode"
      # for each. But fortunately this fact is documented for most of them in the manpage.
      commaSeparated = [
        "Ciphers"
        "KexAlgorithms"
        "Macs"
      ];
      spaceSeparated = [
        "AcceptEnv"
        "AuthorizedKeysFile"
        "AllowGroups"
        "AllowUsers"
        "DenyGroups"
        "DenyUsers"
      ];
    in
    {
      inherit (base) type;

      generate =
        name: value:
        let
          transformedValue = lib.mapAttrs (
            key: val:
            if lib.isList val then
              if lib.elem key commaSeparated then
                lib.concatStringsSep "," val
              else if lib.elem key spaceSeparated then
                lib.concatStringsSep " " val
              else
                throw "list value for unknown key ${key}: ${(lib.generators.toPretty { }) val}"
            else
              val
          ) value;
        in
        base.generate name transformedValue;
    };

  configFile = settingsFormat.generate "sshd.conf-settings" (
    lib.filterAttrs (n: v: v != null) cfg.settings
  );
  sshconf = pkgs.runCommand "sshd.conf-final" { } ''
    cat ${configFile} - >$out <<EOL
    ${cfg.extraConfig}
    EOL
  '';

  cfg = config.services.openssh;
  cfgc = config.programs.ssh;

  nssModulesPath = config.system.nssModules.path;

  userOptions = {

    options.openssh.authorizedKeys = {
      keyFiles = lib.mkOption {
        default = [ ];

        description = ''
          A list of files each containing one OpenSSH public key that should be
          added to the user's authorized keys. The contents of the files are
          read at build time and added to a file that the SSH daemon reads in
          addition to the the user's authorized_keys file. You can combine the
          `keyFiles` and `keys` options.
        '';

        type = lib.types.listOf lib.types.path;
      };

      keys = lib.mkOption {
        default = [ ];

        description = ''
          A list of verbatim OpenSSH public keys that should be added to the
          user's authorized keys. The keys are added to a file that the SSH
          daemon reads in addition to the the user's authorized_keys file.
          You can combine the `keys` and
          `keyFiles` options.
          Warning: If you are using `NixOps` then don't use this
          option since it will replace the key required for deployment via ssh.
        '';

        example = [
          "ssh-rsa AAAAB3NzaC1yc2etc/etc/etcjwrsh8e596z6J0l7 example@host"
          "ssh-ed25519 AAAAC3NzaCetcetera/etceteraJZMfk3QPfQ foo@bar"
        ];

        type = lib.types.listOf lib.types.singleLineStr;
      };
    };

    options.openssh.authorizedPrincipals = lib.mkOption {
      default = [ ];

      description = ''
        A list of verbatim principal names that should be added to the user's
        authorized principals.
      '';

      example = [
        "example@host"
        "foo@bar"
      ];

      type = with lib.types; listOf lib.types.singleLineStr;
    };

  };

  authKeysFiles =
    let
      mkAuthKeyFile =
        u:
        lib.nameValuePair "ssh/authorized_keys.d/${u.name}" {
          mode = "0444";

          source = pkgs.writeText "${u.name}-authorized_keys" ''
            ${lib.concatStringsSep "\n" u.openssh.authorizedKeys.keys}
            ${lib.concatMapStrings (f: lib.readFile f + "\n") u.openssh.authorizedKeys.keyFiles}
          '';
        };
      usersWithKeys = lib.attrValues (
        lib.flip lib.filterAttrs config.users.users (
          n: u:
          lib.length u.openssh.authorizedKeys.keys != 0 || lib.length u.openssh.authorizedKeys.keyFiles != 0
        )
      );
    in
    lib.listToAttrs (map mkAuthKeyFile usersWithKeys);

  authPrincipalsFiles =
    let
      mkAuthPrincipalsFile =
        u:
        lib.nameValuePair "ssh/authorized_principals.d/${u.name}" {
          mode = "0444";
          text = lib.concatStringsSep "\n" u.openssh.authorizedPrincipals;
        };
      usersWithPrincipals = lib.attrValues (
        lib.flip lib.filterAttrs config.users.users (n: u: lib.length u.openssh.authorizedPrincipals != 0)
      );
    in
    lib.listToAttrs (map mkAuthPrincipalsFile usersWithPrincipals);

in

{
  imports = [
    (lib.mkAliasOptionModule [ "services" "sshd" "enable" ] [ "services" "openssh" "enable" ])
    (lib.mkAliasOptionModule [ "services" "openssh" "knownHosts" ] [ "programs" "ssh" "knownHosts" ])
    (lib.mkRenamedOptionModule
      [ "services" "openssh" "challengeResponseAuthentication" ]
      [ "services" "openssh" "kbdInteractiveAuthentication" ]
    )

    (lib.mkRenamedOptionModule
      [ "services" "openssh" "kbdInteractiveAuthentication" ]
      [ "services" "openssh" "settings" "KbdInteractiveAuthentication" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "openssh" "passwordAuthentication" ]
      [ "services" "openssh" "settings" "PasswordAuthentication" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "openssh" "useDns" ]
      [ "services" "openssh" "settings" "UseDns" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "openssh" "permitRootLogin" ]
      [ "services" "openssh" "settings" "PermitRootLogin" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "openssh" "logLevel" ]
      [ "services" "openssh" "settings" "LogLevel" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "openssh" "macs" ]
      [ "services" "openssh" "settings" "Macs" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "openssh" "ciphers" ]
      [ "services" "openssh" "settings" "Ciphers" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "openssh" "kexAlgorithms" ]
      [ "services" "openssh" "settings" "KexAlgorithms" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "openssh" "gatewayPorts" ]
      [ "services" "openssh" "settings" "GatewayPorts" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "openssh" "forwardX11" ]
      [ "services" "openssh" "settings" "X11Forwarding" ]
    )
    (lib.mkRemovedOptionModule [
      "services"
      "openssh"
      "banner"
    ] "Use services.openssh.settings.Banner instead.")
  ];

  ###### interface

  options = {

    services.openssh = {

      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to enable the OpenSSH secure shell daemon, which
          allows secure remote logins.
        '';

        type = lib.types.bool;
      };

      package = lib.mkOption {
        default = config.programs.ssh.package;
        defaultText = lib.literalExpression "programs.ssh.package";
        description = "OpenSSH package to use for sshd.";
        type = lib.types.package;
      };

      allowSFTP = lib.mkOption {
        default = true;

        description = ''
          Whether to enable the SFTP subsystem in the SSH daemon.  This
          enables the use of commands such as {command}`sftp` and
          {command}`sshfs`.
        '';

        type = lib.types.bool;
      };

      authorizedKeysCommand = lib.mkOption {
        default = "none";

        description = ''
          Specifies a program to be used to look up the user's public
          keys. The program must be owned by root, not writable by group
          or others and specified by an absolute path.
        '';

        type = lib.types.str;
      };

      authorizedKeysCommandUser = lib.mkOption {
        default = "nobody";

        description = ''
          Specifies the user under whose account the AuthorizedKeysCommand
          is run. It is recommended to use a dedicated user that has no
          other role on the host than running authorized keys commands.
        '';

        type = lib.types.str;
      };

      authorizedKeysFiles = lib.mkOption {
        default = [ ];

        description = ''
          Specify the rules for which files to read on the host.

          This is an advanced option. If you're looking to configure user
          keys, you can generally use [](#opt-users.users._name_.openssh.authorizedKeys.keys)
          or [](#opt-users.users._name_.openssh.authorizedKeys.keyFiles).

          These are paths relative to the host root file system or home
          directories and they are subject to certain token expansion rules.
          See AuthorizedKeysFile in man sshd_config for details.
        '';

        type = lib.types.listOf lib.types.str;
      };

      authorizedKeysInHomedir = lib.mkOption {
        default = true;

        description = ''
          Enables the use of the `~/.ssh/authorized_keys` file.

          Otherwise, the only files trusted by default are those in `/etc/ssh/authorized_keys.d`,
          *i.e.* SSH keys from [](#opt-users.users._name_.openssh.authorizedKeys.keys).
        '';

        type = lib.types.bool;
      };

      enableRecommendedAlgorithms = lib.mkOption {
        default = true;

        description = ''
          Use algorithms curated and recommended by NixOS.

          Set to false to use upstream's default algorithms.
        '';

        type = lib.types.bool;
      };

      extraConfig = lib.mkOption {
        default = "";
        description = "Verbatim contents of {file}`sshd_config`.";
        type = lib.types.lines;
      };

      generateHostKeys = lib.mkOption {
        default = config.services.openssh.enable;
        defaultText = lib.literalExpression "services.openssh.enable";

        description = ''
          Whether to generate SSH host keys.

          This can be enabled explicitly if you want to generate host keys but
          don't want to enable the SSH daemon.
        '';

        example = true;
        type = lib.types.bool;
      };

      hostKeys = lib.mkOption {
        default = [
          {
            bits = 4096;
            path = "/etc/ssh/ssh_host_rsa_key";
            type = "rsa";
          }
          {
            path = "/etc/ssh/ssh_host_ed25519_key";
            type = "ed25519";
          }
        ];

        description = ''
          NixOS can automatically generate SSH host keys.  This option
          specifies the path, type and size of each key.  See
          {manpage}`ssh-keygen(1)` for supported types
          and sizes.
        '';

        example = [
          {
            bits = 4096;
            openSSHFormat = true;
            path = "/etc/ssh/ssh_host_rsa_key";
            type = "rsa";
          }
          {
            comment = "key comment";
            path = "/etc/ssh/ssh_host_ed25519_key";
            type = "ed25519";
          }
        ];

        type = lib.types.listOf lib.types.attrs;
      };

      listenAddresses = lib.mkOption {
        default = [ ];

        description = ''
          List of addresses and ports to listen on (ListenAddress directive
          in config). If port is not specified for address sshd will listen
          on all ports specified by `ports` option.
          NOTE: this will override default listening on all local addresses and port 22.
          NOTE: setting this option won't automatically enable given ports
          in firewall configuration.
          NOTE: If the IP address is not available at boot time, the following has
          to be added to make sure sshd will wait for dhcp configuration:
          ```nix
          systemd.services.sshd = {
            wants = [ "network-online.target" ];
            after = [ "network-online.target" ];
          };
          ```
          See the following issue for details: <https://github.com/NixOS/nixpkgs/issues/105570>
        '';

        example = [
          {
            addr = "192.168.3.1";
            port = 22;
          }
          {
            addr = "0.0.0.0";
            port = 64022;
          }
        ];

        type =
          with lib.types;
          listOf (submodule {
            options = {
              addr = lib.mkOption {
                default = null;

                description = ''
                  Host, IPv4 or IPv6 address to listen to.
                '';

                type = lib.types.nullOr lib.types.str;
              };

              port = lib.mkOption {
                default = null;

                description = ''
                  Port to listen to.
                '';

                type = lib.types.nullOr lib.types.port;
              };
            };
          });
      };

      moduliFile = lib.mkOption {
        description = ''
          Path to `moduli` file to install in
          `/etc/ssh/moduli`. If this option is unset, then
          the `moduli` file shipped with OpenSSH will be used.
        '';

        example = "/etc/my-local-ssh-moduli;";
        type = lib.types.path;
      };

      openFirewall = lib.mkOption {
        default = true;

        description = ''
          Whether to automatically open the specified ports in the firewall.
        '';

        type = lib.types.bool;
      };

      ports = lib.mkOption {
        default = [ 22 ];

        description = ''
          Specifies on which ports the SSH daemon listens.
        '';

        type = lib.types.listOf lib.types.port;
      };

      settings = lib.mkOption {
        default = { };
        description = "Configuration for `sshd_config(5)`.";

        example = lib.literalExpression ''
          {
            UseDns = true;
            PasswordAuthentication = false;
          }
        '';

        type = lib.types.submodule (
          { name, ... }:
          {
            options = {
              AcceptEnv = lib.mkOption {
                default = null;

                description = ''
                  Specifies what environment variables sent by the client will be copied into the session's
                  environment. The TERM environment variable is always accepted whenever the client requests
                  a pseudo-terminal as it is required by the protocol.
                '';

                type = lib.types.nullOr (lib.types.listOf lib.types.str);
              };

              AllowGroups = lib.mkOption {
                default = null;

                description = ''
                  If specified, login is allowed only for users part of the
                  listed groups.
                  See {manpage}`sshd_config(5)` for details.
                '';

                type = with lib.types; nullOr (listOf str);
              };

              AllowUsers = lib.mkOption {
                default = null;

                description = ''
                  If specified, login is allowed only for the listed users.
                  See {manpage}`sshd_config(5)` for details.
                '';

                type = with lib.types; nullOr (listOf str);
              };

              AuthorizedPrincipalsFile = lib.mkOption {
                default = "none"; # upstream default

                description = ''
                  Specifies a file that lists principal names that are accepted for certificate authentication. The default
                  is `"none"`, i.e. not to use a principals file.
                '';

                type = lib.types.nullOr lib.types.str;
              };

              Banner = lib.mkOption {
                default = null;

                description = ''
                  The file whose contents are sent to the remote user before authentication.
                '';

                example = "/etc/ssh/banner";
                type = lib.types.nullOr lib.types.path;
              };

              Ciphers = lib.mkOption {
                default =
                  if config.services.openssh.enableRecommendedAlgorithms then
                    [
                      "chacha20-poly1305@openssh.com"
                      "aes256-gcm@openssh.com"
                      "aes128-gcm@openssh.com"
                      "aes256-ctr"
                      "aes192-ctr"
                      "aes128-ctr"
                    ]
                  else
                    null;

                defaultText = ''
                  if config.services.openssh.enableRecommendedAlgorithms then
                    [
                      "chacha20-poly1305@openssh.com"
                      "aes256-gcm@openssh.com"
                      "aes128-gcm@openssh.com"
                      "aes256-ctr"
                      "aes192-ctr"
                      "aes128-ctr"
                    ]
                  else
                    null;
                '';

                description = ''
                  Allowed ciphers

                  Defaults to a curated set of algorithms.
                  Set enableRecommendedAlgorithms to false to use upstream's defaults.
                '';

                type = lib.types.nullOr (lib.types.listOf lib.types.str);
              };

              DenyGroups = lib.mkOption {
                default = null;

                description = ''
                  If specified, login is denied for all users part of the listed
                  groups. Takes precedence over
                  [](#opt-services.openssh.settings.AllowGroups). See
                  {manpage}`sshd_config(5)` for details.
                '';

                type = with lib.types; nullOr (listOf str);
              };

              DenyUsers = lib.mkOption {
                default = null;

                description = ''
                  If specified, login is denied for all listed users. Takes
                  precedence over [](#opt-services.openssh.settings.AllowUsers).
                  See {manpage}`sshd_config(5)` for details.
                '';

                type = with lib.types; nullOr (listOf str);
              };

              GatewayPorts = lib.mkOption {
                default = "no";

                description = ''
                  Specifies whether remote hosts are allowed to connect to
                  ports forwarded for the client.  See
                  {manpage}`sshd_config(5)`.
                '';

                type = lib.types.nullOr lib.types.str;
              };

              KbdInteractiveAuthentication = lib.mkOption {
                default = true;

                description = ''
                  Specifies whether keyboard-interactive authentication is allowed.
                '';

                type = lib.types.nullOr lib.types.bool;
              };

              KexAlgorithms = lib.mkOption {
                default =
                  if config.services.openssh.enableRecommendedAlgorithms then
                    [
                      "mlkem768x25519-sha256"
                      "sntrup761x25519-sha512"
                      "sntrup761x25519-sha512@openssh.com"
                      "curve25519-sha256"
                      "curve25519-sha256@libssh.org"
                      "diffie-hellman-group-exchange-sha256"
                    ]
                  else
                    null;

                defaultText = ''
                  if config.services.openssh.enableRecommendedAlgorithms then
                    [
                      "mlkem768x25519-sha256"
                      "sntrup761x25519-sha512"
                      "sntrup761x25519-sha512@openssh.com"
                      "curve25519-sha256"
                      "curve25519-sha256@libssh.org"
                      "diffie-hellman-group-exchange-sha256"
                    ]
                  else
                    null;
                '';

                description = ''
                  Allowed key exchange algorithms

                  Defaults to a curated set of algorithms.
                  Set enableRecommendedAlgorithms to false to use upstream's defaults.
                '';

                type = lib.types.nullOr (lib.types.listOf lib.types.str);
              };

              LogLevel = lib.mkOption {
                default = "INFO"; # upstream default

                description = ''
                  Gives the verbosity level that is used when logging messages from {manpage}`sshd(8)`. Logging with a DEBUG level
                  violates the privacy of users and is not recommended.
                '';

                type = lib.types.nullOr (
                  lib.types.enum [
                    "QUIET"
                    "FATAL"
                    "ERROR"
                    "INFO"
                    "VERBOSE"
                    "DEBUG"
                    "DEBUG1"
                    "DEBUG2"
                    "DEBUG3"
                  ]
                );
              };

              Macs = lib.mkOption {
                default =
                  if config.services.openssh.enableRecommendedAlgorithms then
                    [
                      "hmac-sha2-512-etm@openssh.com"
                      "hmac-sha2-256-etm@openssh.com"
                      "umac-128-etm@openssh.com"
                    ]
                  else
                    null;

                defaultText = ''
                  if config.services.openssh.enableRecommendedAlgorithms then
                    [
                      "hmac-sha2-512-etm@openssh.com"
                      "hmac-sha2-256-etm@openssh.com"
                      "umac-128-etm@openssh.com"
                    ]
                  else
                    null;
                '';

                description = ''
                  Allowed MACs

                  Defaults to a curated set of algorithms.
                  Set enableRecommendedAlgorithms to false to use upstream's defaults.
                '';

                type = lib.types.nullOr (lib.types.listOf lib.types.str);
              };

              PasswordAuthentication = lib.mkOption {
                default = true;

                description = ''
                  Specifies whether password authentication is allowed.
                '';

                type = lib.types.nullOr lib.types.bool;
              };

              PermitRootLogin = lib.mkOption {
                default = "prohibit-password";

                description = ''
                  Whether the root user can login using ssh.
                '';

                type = lib.types.nullOr (
                  lib.types.enum [
                    "yes"
                    "without-password"
                    "prohibit-password"
                    "forced-commands-only"
                    "no"
                  ]
                );
              };

              # Disabled by default, since pam_motd handles this.
              PrintMotd = lib.mkEnableOption "printing /etc/motd when a user logs in interactively" // {
                type = lib.types.nullOr lib.types.bool;
              };

              StrictModes = lib.mkOption {
                default = true;

                description = ''
                  Whether sshd should check file modes and ownership of directories
                '';

                type = lib.types.nullOr (lib.types.bool);
              };

              UseDns = lib.mkOption {
                default = false;

                description = ''
                  Specifies whether {manpage}`sshd(8)` should look up the remote host name, and to check that the resolved host name for
                  the remote IP address maps back to the very same IP address.
                  If this option is set to no (the default) then only addresses and not host names may be used in
                  ~/.ssh/authorized_keys from and sshd_config Match Host directives.
                '';

                type = lib.types.nullOr lib.types.bool;
              };

              UsePAM = lib.mkEnableOption "PAM authentication" // {
                default = true;
                type = lib.types.nullOr lib.types.bool;
              };

              X11Forwarding = lib.mkOption {
                default = false;

                description = ''
                  Whether to allow X11 connections to be forwarded.
                '';

                type = lib.types.nullOr lib.types.bool;
              };
            };

            freeformType = settingsFormat.type;
          }
        );
      };

      sftpFlags = lib.mkOption {
        default = [ ];

        description = ''
          Commandline flags to add to sftp-server.
        '';

        example = [
          "-f AUTHPRIV"
          "-l INFO"
        ];

        type = with lib.types; listOf str;
      };

      sftpServerExecutable = lib.mkOption {
        description = ''
          The sftp server executable.  Can be a path or "internal-sftp" to use
          the sftp server built into the sshd binary.
        '';

        example = "internal-sftp";
        type = lib.types.str;
      };

      startWhenNeeded = lib.mkOption {
        default = false;

        description = ''
          If set, {command}`sshd` is socket-activated; that
          is, instead of having it permanently running as a daemon,
          systemd will start an instance for each incoming connection.
        '';

        type = lib.types.bool;
      };

    };

    users.users = lib.mkOption {
      type = with lib.types; attrsOf (submodule userOptions);
    };

  };

  ###### implementation

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {

      assertions = [
        {
          assertion = if cfg.settings.X11Forwarding then cfgc.setXAuthLocation else true;
          message = "cannot enable X11 forwarding without setting xauth location";
        }
        {
          assertion =
            (builtins.match "(.*\n)?(\t )*[Kk][Ee][Rr][Bb][Ee][Rr][Oo][Ss][Aa][Uu][Tt][Hh][Ee][Nn][Tt][Ii][Cc][Aa][Tt][Ii][Oo][Nn][ |\t|=|\"]+yes.*" "${configFile}\n${cfg.extraConfig}")
            != null
            -> cfgc.package.withKerberos;

          message = "cannot enable Kerberos authentication without using a package with Kerberos support";
        }
        {
          assertion =
            (builtins.match "(.*\n)?(\t )*[Gg][Ss][Ss][Aa][Pp][Ii][Aa][Uu][Tt][Hh][Ee][Nn][Tt][Ii][Cc][Aa][Tt][Ii][Oo][Nn][ |\t|=|\"]+yes.*" "${configFile}\n${cfg.extraConfig}")
            != null
            -> cfgc.package.withKerberos;

          message = "cannot enable GSSAPI authentication without using a package with Kerberos support";
        }
        (
          let
            duplicates =
              # Filter out the groups with more than 1 element
              lib.filter (l: lib.length l > 1) (
                # Grab the groups, we don't care about the group identifiers
                lib.attrValues (
                  # Group the settings that are the same in lower case
                  lib.groupBy lib.strings.toLower (lib.attrNames cfg.settings)
                )
              );
            formattedDuplicates = lib.concatMapStringsSep ", " (
              dupl: "(${lib.concatStringsSep ", " dupl})"
            ) duplicates;
          in
          {
            assertion = lib.length duplicates == 0;
            message = "Duplicate sshd config key; does your capitalization match the option's? Duplicate keys: ${formattedDuplicates}";
          }
        )
      ]
      ++ lib.forEach cfg.listenAddresses (
        { addr, ... }:
        {
          assertion = addr != null;
          message = "addr must be specified in each listenAddresses entry";
        }
      );

      environment.etc =
        authKeysFiles
        // authPrincipalsFiles
        // {
          "ssh/moduli".source = cfg.moduliFile;
          "ssh/sshd_config".source = sshconf;
        };

      networking.firewall.allowedTCPPorts = lib.optionals cfg.openFirewall cfg.ports;

      security.pam.services.sshd = lib.mkIf (cfg.settings.UsePAM == true) {
        showMotd = true;
        startSession = true;
        unixAuth = if cfg.settings.PasswordAuthentication == true then true else false;
      };

      # These values are merged with the ones defined externally, see:
      # https://github.com/NixOS/nixpkgs/pull/10155
      # https://github.com/NixOS/nixpkgs/pull/41745
      services.openssh.authorizedKeysFiles =
        lib.optional cfg.authorizedKeysInHomedir "%h/.ssh/authorized_keys"
        ++ [ "/etc/ssh/authorized_keys.d/%u" ];

      services.openssh.extraConfig = lib.mkOrder 0 (
        lib.concatStringsSep "\n" (
          [
            "AddressFamily ${if config.networking.enableIPv6 then "any" else "inet"}"
          ]
          ++ lib.map (port: "Port ${toString port}") cfg.ports
          ++ lib.map (
            { addr, port, ... }:
            "ListenAddress ${addr}${lib.optionalString (port != null) (":" + toString port)}"
          ) cfg.listenAddresses
          ++ lib.optional cfgc.setXAuthLocation "XAuthLocation ${lib.getExe pkgs.xauth}"
          ++ lib.optional cfg.allowSFTP "Subsystem sftp ${cfg.sftpServerExecutable} ${lib.concatStringsSep " " cfg.sftpFlags}"
          ++ [
            "AuthorizedKeysFile ${toString cfg.authorizedKeysFiles}"
          ]
          ++ lib.optional (cfg.authorizedKeysCommand != "none") ''
            AuthorizedKeysCommand ${cfg.authorizedKeysCommand}
            AuthorizedKeysCommandUser ${cfg.authorizedKeysCommandUser}
          ''
          ++ lib.map (k: "HostKey ${k.path}") cfg.hostKeys
        )
      );

      services.openssh.moduliFile = lib.mkDefault "${cfg.package}/etc/ssh/moduli";

      services.openssh.settings.AuthorizedPrincipalsFile = lib.mkIf (
        authPrincipalsFiles != { }
      ) "/etc/ssh/authorized_principals.d/%u";

      services.openssh.sftpServerExecutable = lib.mkDefault "${cfg.package}/libexec/sftp-server";

      system.checks = [
        (pkgs.runCommand "check-sshd-config"
          {
            nativeBuildInputs = [ validationPackage.out ];
          }
          ''
            ${lib.concatMapStringsSep "\n" (
              lport: "sshd -G -T -C lport=${toString lport} -f ${sshconf} > /dev/null"
            ) cfg.ports}
            ${lib.concatMapStringsSep "\n" (
              la:
              lib.concatMapStringsSep "\n" (
                port:
                "sshd -G -T -C ${lib.escapeShellArg "laddr=${la.addr},lport=${toString port}"} -f ${sshconf} > /dev/null"
              ) (if la.port != null then [ la.port ] else cfg.ports)
            ) cfg.listenAddresses}
            touch $out
          ''
        )
      ];

      systemd = {
        generatorPath = [ cfg.package ];

        services.sshd = lib.mkIf (!cfg.startWhenNeeded) {
          after = [
            "network.target"
            "sshd-keygen.service"
          ];

          description = "SSH Daemon";
          environment.LD_LIBRARY_PATH = nssModulesPath;
          path = [ cfg.package ];
          restartTriggers = [ config.environment.etc."ssh/sshd_config".source ];

          serviceConfig = {
            ExecStart = lib.concatStringsSep " " [
              (lib.getExe' cfg.package "sshd")
              "-D"
              "-f"
              "/etc/ssh/sshd_config"
            ];

            KillMode = "process";
            Restart = "always";
            Type = "notify-reload";
          };

          stopIfChanged = false;
          wantedBy = [ "multi-user.target" ];
          wants = lib.mkIf cfg.generateHostKeys [ "sshd-keygen.service" ];
        };

        services."sshd@" = {
          after = [
            "network.target"
            "sshd-keygen.service"
          ];

          description = "SSH per-connection Daemon";
          environment.LD_LIBRARY_PATH = nssModulesPath;
          path = [ cfg.package ];

          serviceConfig = {
            ExecStart = lib.concatStringsSep " " [
              "-${lib.getExe' cfg.package "sshd"}"
              "-i"
              "-D"
              "-f /etc/ssh/sshd_config"
            ];

            KillMode = "process";
            StandardError = "journal";
            StandardInput = "socket";
          };

          stopIfChanged = false;
          wants = lib.mkIf cfg.generateHostKeys [ "sshd-keygen.service" ];
        };

        sockets.sshd = lib.mkIf cfg.startWhenNeeded {
          description = "SSH Socket";
          socketConfig.Accept = true;

          socketConfig.ListenStream =
            if cfg.listenAddresses != [ ] then
              lib.concatMap (
                { addr, port }:
                if port != null then [ "${addr}:${toString port}" ] else map (p: "${addr}:${toString p}") cfg.ports
              ) cfg.listenAddresses
            else
              cfg.ports;

          # Prevent brute-force attacks from shutting down socket
          socketConfig.TriggerLimitIntervalSec = 0;
          wantedBy = [ "sockets.target" ];
        };
      };

      systemd.tmpfiles.settings."ssh-root-provision" = {
        "/root"."d-" = {
          group = ":root";
          mode = ":700";
          user = "root";
        };

        "/root/.ssh"."d-" = {
          group = ":root";
          mode = ":700";
          user = "root";
        };

        "/root/.ssh/authorized_keys"."f^" = {
          argument = "ssh.authorized_keys.root";
          group = ":root";
          mode = ":600";
          user = "root";
        };
      };

      users.groups.sshd = { };

      users.users.sshd = {
        description = "SSH privilege separation user";
        group = "sshd";
        isSystemUser = true;
      };
    })

    (lib.mkIf cfg.generateHostKeys {
      systemd.services.sshd-keygen = {
        description = "SSH Host Keys Generation";
        path = [ cfg.package ];

        script = lib.flip lib.concatMapStrings cfg.hostKeys (k: ''
          if ! [ -s "${k.path}" ]; then
              if ! [ -h "${k.path}" ]; then
                  rm -f "${k.path}"
              fi
              mkdir -p "$(dirname '${k.path}')"
              chmod 0755 "$(dirname '${k.path}')"
              ssh-keygen \
                -t "${k.type}" \
                ${lib.optionalString (k ? bits) "-b ${toString k.bits}"} \
                ${lib.optionalString (k ? comment) "-C '${k.comment}'"} \
                ${lib.optionalString (k ? openSSHFormat && k.openSSHFormat) "-o"} \
                -f "${k.path}" \
                -N ""
          fi
        '');

        serviceConfig = {
          Type = "oneshot";
        };

        unitConfig = {
          ConditionFileNotEmpty = map (k: "|!${k.path}") cfg.hostKeys;
        };

        wantedBy = [ "multi-user.target" ];
      };
    })
  ];

}
