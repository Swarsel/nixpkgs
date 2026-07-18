{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.public-inbox;
  stateDir = "/var/lib/public-inbox";

  gitIni = pkgs.formats.gitIni { listsAsDuplicateKeys = true; };
  iniAtom = gitIni.lib.types.atom;

  useSpamAssassin =
    cfg.settings.publicinboxmda.spamcheck == "spamc"
    || cfg.settings.publicinboxwatch.spamcheck == "spamc";

  publicInboxDaemonOptions = proto: defaultPort: {
    args = mkOption {
      default = [ ];
      description = "Command-line arguments to pass to {manpage}`public-inbox-${proto}d(1)`.";
      type = with types; listOf str;
    };

    cert = mkOption {
      default = null;
      description = "Path to TLS certificate to use for connections to {manpage}`public-inbox-${proto}d(1)`.";
      example = "/path/to/fullchain.pem";
      type = with types; nullOr str;
    };

    key = mkOption {
      default = null;
      description = "Path to TLS key to use for connections to {manpage}`public-inbox-${proto}d(1)`.";
      example = "/path/to/key.pem";
      type = with types; nullOr str;
    };

    port = mkOption {
      default = defaultPort;

      description = ''
        Listening port.
        Beware that public-inbox uses well-known ports number to decide whether to enable TLS or not.
        Set to null and use `systemd.sockets.public-inbox-${proto}d.listenStreams`
        if you need a more advanced listening.
      '';

      type = with types; nullOr (either str port);
    };
  };

  serviceConfig =
    srv:
    let
      proto = removeSuffix "d" srv;
      needNetwork = builtins.hasAttr proto cfg && cfg.${proto}.port == null;
    in
    {
      confinement = {
        enable = true;
        # Inline::C needs a /bin/sh, and dash is enough
        binSh = "${pkgs.dash}/bin/dash";
        mode = "full-apivfs";

        packages = [
          pkgs.iana-etc
          (getLib pkgs.nss)
          pkgs.tzdata
        ];
      };

      serviceConfig = {
        # The following options are only for optimizing:
        # systemd-analyze security public-inbox-'*'
        AmbientCapabilities = "";

        BindReadOnlyPaths = [
          "/etc"
          "/run/systemd"
        ]
        ++ lib.optionals (config.i18n.glibcLocales != null) [
          "${config.i18n.glibcLocales}"
        ]
        ++ mapAttrsToList (name: inbox: inbox.description) cfg.inboxes
        ++ filter (x: x != null) [
          cfg.${proto}.cert or null
          cfg.${proto}.key or null
        ];

        CapabilityBoundingSet = "";
        # ProtectClock= adds DeviceAllow=char-rtc r
        DeviceAllow = "";
        # Enable JIT-compiled C (via Inline::C)
        Environment = [ "PERL_INLINE_DIRECTORY=/run/public-inbox-${srv}/perl-inline" ];
        Group = config.users.groups."public-inbox".name;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        # NonBlocking is REQUIRED to avoid a race condition
        # if running simultaneous services.
        NonBlocking = true;
        PrivateNetwork = mkDefault (!needNetwork);
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectHome = "tmpfs";
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        RemoveIPC = true;

        RestrictAddressFamilies = [
          "AF_UNIX"
        ]
        ++ optionals needNetwork [
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;

        RuntimeDirectory = [
          "public-inbox-${srv}/perl-inline"
        ];

        RuntimeDirectoryMode = "700";
        StateDirectory = [ "public-inbox" ];
        StateDirectoryMode = "0750";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@aio"
          "~@chown"
          "~@keyring"
          "~@memlock"
          "~@resources"
          # Not removing @setuid and @privileged because Inline::C needs them.
          # Not removing @timer because git upload-pack needs it.
        ];

        # This is for BindPaths= and BindReadOnlyPaths=
        # to allow traversal of directories they create inside RootDirectory=
        UMask = "0066";
        #LimitNOFILE = 30000;
        User = config.users.users."public-inbox".name;
        WorkingDirectory = stateDir;
      };
    };
in

{
  options.services.public-inbox = {
    enable = mkEnableOption "the public-inbox mail archiver";
    package = mkPackageOption pkgs "public-inbox" { };

    http = {
      enable = mkEnableOption "the public-inbox HTTP server";
      args = (publicInboxDaemonOptions "http" 80).args;

      mounts = mkOption {
        default = [ "/" ];

        description = ''
          Root paths or URLs that public-inbox will be served on.
          If domain parts are present, only requests to those
          domains will be accepted.
        '';

        example = [ "/lists/archives" ];
        type = with types; listOf str;
      };

      port = mkOption {
        default = 80;

        description = ''
          Listening port or systemd's ListenStream= entry
          to be used as a reverse proxy, eg. in nginx:
          `locations."/inbox".proxyPass = "http://unix:''${config.services.public-inbox.http.port}:/inbox";`
          Set to null and use `systemd.sockets.public-inbox-httpd.listenStreams`
          if you need a more advanced listening.
        '';

        example = "/run/public-inbox-httpd.sock";
        type = with types; nullOr (either str port);
      };
    };

    imap = {
      enable = mkEnableOption "the public-inbox IMAP server";
    }
    // publicInboxDaemonOptions "imap" 993;

    inboxes = mkOption {
      default = { };

      description = ''
        Inboxes to configure, where attribute names are inbox names.
      '';

      type = types.attrsOf (
        types.submodule (
          { name, ... }:
          {
            options.address = mkOption {
              description = "The email addresses of the public-inbox.";
              example = "example-discuss@example.org";
              type = with types; listOf str;
            };

            options.coderepo = mkOption {
              default = [ ];
              description = "Nicknames of a 'coderepo' section associated with the inbox.";

              type = (types.listOf (types.enum (attrNames cfg.settings.coderepo))) // {
                description = "list of coderepo names";
              };
            };

            options.description = mkOption {
              apply = pkgs.writeText "public-inbox-description-${name}";
              description = "User-visible description for the repository.";
              example = "user/dev discussion of public-inbox itself";
              type = types.str;
            };

            options.inboxdir = mkOption {
              default = "${stateDir}/inboxes/${name}";
              description = "The absolute path to the directory which hosts the public-inbox.";
              type = types.str;
            };

            options.newsgroup = mkOption {
              default = null;
              description = "NNTP group name for the inbox.";
              type = with types; nullOr str;
            };

            options.url = mkOption {
              description = "URL where this inbox can be accessed over HTTP.";
              example = "https://example.org/lists/example-discuss";
              type = types.nonEmptyStr;
            };

            options.watch = mkOption {
              default = [ ];
              description = "Paths for {manpage}`public-inbox-watch(1)` to monitor for new mail.";
              example = [ "maildir:/path/to/test.example.com.git" ];
              type = with types; listOf str;
            };

            options.watchheader = mkOption {
              default = null;

              description = ''
                If specified, {manpage}`public-inbox-watch(1)` will only process
                mail containing a matching header.
              '';

              example = "List-Id:<test@example.com>";
              type = with types; nullOr str;
            };

            freeformType = types.attrsOf iniAtom;
          }
        )
      );
    };

    mda = {
      enable = mkEnableOption "the public-inbox Mail Delivery Agent";

      args = mkOption {
        default = [ ];
        description = "Command-line arguments to pass to {manpage}`public-inbox-mda(1)`.";
        type = with types; listOf str;
      };
    };

    nntp = {
      enable = mkEnableOption "the public-inbox NNTP server";
    }
    // publicInboxDaemonOptions "nntp" 563;

    openFirewall = mkEnableOption "opening the firewall when using a port option";

    path = mkOption {
      default = [ ];

      description = ''
        Additional packages to place in the path of public-inbox-mda,
        public-inbox-watch, etc.
      '';

      example = literalExpression "with pkgs; [ spamassassin ]";
      type = with types; listOf package;
    };

    postfix.enable = mkEnableOption "the integration into Postfix";

    settings = mkOption {
      default = { };

      description = ''
        Settings for the [public-inbox config file](https://public-inbox.org/public-inbox-config.html).
      '';

      type = types.submodule {
        options.coderepo = mkOption {
          default = { };
          description = "code repositories";

          type = types.attrsOf (
            types.submodule {
              options.cgitUrl = mkOption {
                description = "URL of a cgit instance";
                type = types.str;
              };

              options.dir = mkOption {
                description = "Path to a git repository";
                type = types.str;
              };

              freeformType = types.attrsOf iniAtom;
            }
          );
        };

        options.publicinbox = mkOption {
          default = { };
          description = "public inboxes";

          type = types.submodule {
            options.css = mkOption {
              default = [ ];
              description = "The local path name of a CSS file for the PSGI web interface.";
              type = with types; listOf str;
            };

            options.imapserver = mkOption {
              default = [ ];
              description = "IMAP URLs to this public-inbox instance";
              example = [ "imap.public-inbox.org" ];
              type = with types; listOf str;
            };

            options.nntpserver = mkOption {
              default = [ ];
              description = "NNTP URLs to this public-inbox instance";

              example = [
                "nntp://news.public-inbox.org"
                "nntps://news.public-inbox.org"
              ];

              type = with types; listOf str;
            };

            options.pop3server = mkOption {
              default = [ ];
              description = "POP3 URLs to this public-inbox instance";
              example = [ "pop.public-inbox.org" ];
              type = with types; listOf str;
            };

            options.wwwlisting = mkOption {
              default = "404";

              description = ''
                Controls which lists (if any) are listed for when the root
                public-inbox URL is accessed over HTTP.
              '';

              type =
                with types;
                enum [
                  "all"
                  "404"
                  "match=domain"
                ];
            };

            # Support both global options like `services.public-inbox.settings.publicinbox.imapserver`
            # and inbox specific options like `services.public-inbox.settings.publicinbox.foo.address`.
            freeformType =
              with types;
              attrsOf (oneOf [
                iniAtom
                (attrsOf iniAtom)
              ]);
          };
        };

        options.publicinboxmda.spamcheck = mkOption {
          default = "none";

          description = ''
            If set to spamc, {manpage}`public-inbox-watch(1)` will filter spam
            using SpamAssassin.
          '';

          type =
            with types;
            enum [
              "spamc"
              "none"
            ];
        };

        options.publicinboxwatch.spamcheck = mkOption {
          default = "none";

          description = ''
            If set to spamc, {manpage}`public-inbox-watch(1)` will filter spam
            using SpamAssassin.
          '';

          type =
            with types;
            enum [
              "spamc"
              "none"
            ];
        };

        options.publicinboxwatch.watchspam = mkOption {
          default = null;

          description = ''
            If set, mail in this maildir will be trained as spam and
            deleted from all watched inboxes
          '';

          example = "maildir:/path/to/spam";
          type = with types; nullOr str;
        };

        freeformType = gitIni.type;
      };
    };

    spamAssassinRules = mkOption {
      default = "${cfg.package.sa_config}/user/.spamassassin/user_prefs";
      defaultText = literalExpression "\${cfg.package.sa_config}/user/.spamassassin/user_prefs";
      description = "SpamAssassin configuration specific to public-inbox.";
      type = with types; nullOr path;
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = config.services.spamassassin.enable || !useSpamAssassin;

        message = ''
          public-inbox is configured to use SpamAssassin, but
          services.spamassassin.enable is false.  If you don't need
          spam checking, set `services.public-inbox.settings.publicinboxmda.spamcheck' and
          `services.public-inbox.settings.publicinboxwatch.spamcheck' to null.
        '';
      }
      {
        assertion = cfg.path != [ ] || !useSpamAssassin;

        message = ''
          public-inbox is configured to use SpamAssassin, but there is
          no spamc executable in services.public-inbox.path.  If you
          don't need spam checking, set
          `services.public-inbox.settings.publicinboxmda.spamcheck' and
          `services.public-inbox.settings.publicinboxwatch.spamcheck' to null.
        '';
      }
    ];

    environment.systemPackages = [ cfg.package ];

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = mkMerge (
        map
          (proto: (mkIf (cfg.${proto}.enable && types.port.check cfg.${proto}.port) [ cfg.${proto}.port ]))
          [
            "imap"
            "http"
            "nntp"
          ]
      );
    };

    services.postfix = mkIf (cfg.postfix.enable && cfg.mda.enable) {
      # Not sure limiting to 1 is necessary, but better safe than sorry.
      settings.main.public-inbox_destination_recipient_limit = "1";

      # The public-inbox transport
      settings.master.public-inbox = {
        args = [
          "flags=X" # Report as a final delivery
          "user=${with config.users; users."public-inbox".name + ":" + groups."public-inbox".name}"
          # Specifying a nexthop when using the transport
          # (eg. test public-inbox:test) allows to
          # receive mails with an extension (eg. test+foo).
          "argv=${pkgs.writeShellScript "public-inbox-transport" ''
            export HOME="${stateDir}"
            export ORIGINAL_RECIPIENT="''${2:-1}"
            export PATH="${makeBinPath cfg.path}:$PATH"
            exec ${cfg.package}/bin/public-inbox-mda ${escapeShellArgs cfg.mda.args}
          ''} \${original_recipient} \${nexthop}"
        ];

        command = "pipe";
        privileged = true; # Required for user=
        type = "unix";
      };

      # Deliver the addresses with the public-inbox transport
      transport = concatStringsSep "\n" (
        mapAttrsToList (
          _: inbox: concatMapStringsSep "\n" (address: "${address} public-inbox:${address}") inbox.address
        ) cfg.inboxes
      );

      # Register the addresses as existing
      virtual = concatStringsSep "\n" (
        mapAttrsToList (
          _: inbox: concatMapStringsSep "\n" (address: "${address} ${address}") inbox.address
        ) cfg.inboxes
      );
    };

    services.public-inbox.settings = filterAttrsRecursive (n: v: v != null) {
      publicinbox = mapAttrs (n: v: removeAttrs v [ "description" ]) cfg.inboxes;
    };

    systemd.services = mkMerge [
      (mkIf cfg.imap.enable {
        public-inbox-imapd = mkMerge [
          (serviceConfig "imapd")
          {
            after = [
              "public-inbox-init.service"
              "public-inbox-watch.service"
            ];

            requires = [ "public-inbox-init.service" ];

            serviceConfig = {
              ExecStart = escapeShellArgs (
                [ "${cfg.package}/bin/public-inbox-imapd" ]
                ++ cfg.imap.args
                ++ optionals (cfg.imap.cert != null) [
                  "--cert"
                  cfg.imap.cert
                ]
                ++ optionals (cfg.imap.key != null) [
                  "--key"
                  cfg.imap.key
                ]
              );
            };
          }
        ];
      })
      (mkIf cfg.http.enable {
        public-inbox-httpd = mkMerge [
          (serviceConfig "httpd")
          {
            after = [
              "public-inbox-init.service"
              "public-inbox-watch.service"
            ];

            requires = [ "public-inbox-init.service" ];

            serviceConfig = {
              BindReadOnlyPaths = map (c: c.dir) (lib.attrValues cfg.settings.coderepo);

              ExecStart = escapeShellArgs (
                [ "${cfg.package}/bin/public-inbox-httpd" ]
                ++ cfg.http.args
                ++
                  # See https://public-inbox.org/public-inbox.git/tree/examples/public-inbox.psgi
                  # for upstream's example.
                  [
                    (pkgs.writeText "public-inbox.psgi" ''
                      #!${cfg.package.fullperl} -w
                      use strict;
                      use warnings;
                      use Plack::Builder;
                      use PublicInbox::WWW;

                      my $www = PublicInbox::WWW->new;
                      $www->preload;

                      builder {
                        # If reached through a reverse proxy,
                        # make it transparent by resetting some HTTP headers
                        # used by public-inbox to generate URIs.
                        enable 'ReverseProxy';

                        # No need to send a response body if it's an HTTP HEAD requests.
                        enable 'Head';

                        # Route according to configured domains and root paths.
                        ${concatMapStrings (path: ''
                          mount q(${path}) => sub { $www->call(@_); };
                        '') cfg.http.mounts}
                      }
                    '')
                  ]
              );
            };
          }
        ];
      })
      (mkIf cfg.nntp.enable {
        public-inbox-nntpd = mkMerge [
          (serviceConfig "nntpd")
          {
            after = [
              "public-inbox-init.service"
              "public-inbox-watch.service"
            ];

            requires = [ "public-inbox-init.service" ];

            serviceConfig = {
              ExecStart = escapeShellArgs (
                [ "${cfg.package}/bin/public-inbox-nntpd" ]
                ++ cfg.nntp.args
                ++ optionals (cfg.nntp.cert != null) [
                  "--cert"
                  cfg.nntp.cert
                ]
                ++ optionals (cfg.nntp.key != null) [
                  "--key"
                  cfg.nntp.key
                ]
              );
            };
          }
        ];
      })
      (mkIf
        (
          any (inbox: inbox.watch != [ ]) (attrValues cfg.inboxes)
          || cfg.settings.publicinboxwatch.watchspam != null
        )
        {
          public-inbox-watch = mkMerge [
            (serviceConfig "watch")
            {
              inherit (cfg) path;

              requires = [
                "public-inbox-init.service"
              ]
              ++ optional (cfg.settings.publicinboxwatch.spamcheck == "spamc") "spamassassin.service";

              serviceConfig = {
                ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
                ExecStart = "${cfg.package}/bin/public-inbox-watch";
              };

              wantedBy = [ "multi-user.target" ];
              wants = [ "public-inbox-init.service" ];
            }
          ];
        }
      )
      {
        public-inbox-init =
          let
            PI_CONFIG = gitIni.generate "public-inbox.ini" (
              filterAttrsRecursive (n: v: v != null) cfg.settings
            );
          in
          mkMerge [
            (serviceConfig "init")
            {
              restartIfChanged = true;
              restartTriggers = [ PI_CONFIG ];

              script = ''
                set -ux
                install -D -p ${PI_CONFIG} ${stateDir}/.public-inbox/config
              ''
              + optionalString useSpamAssassin ''
                install -m 0700 -o spamd -d ${stateDir}/.spamassassin
                ${optionalString (cfg.spamAssassinRules != null) ''
                  ln -sf ${cfg.spamAssassinRules} ${stateDir}/.spamassassin/user_prefs
                ''}
              ''
              + concatStrings (
                mapAttrsToList (name: inbox: ''
                  if [ ! -e ${escapeShellArg inbox.inboxdir} ]; then
                    # public-inbox-init creates an inbox and adds it to a config file.
                    # It tries to atomically write the config file by creating
                    # another file in the same directory, and renaming it.
                    # This has the sad consequence that we can't use
                    # /dev/null, or it would try to create a file in /dev.
                    conf_dir="$(mktemp -d)"

                    PI_CONFIG=$conf_dir/conf \
                    ${cfg.package}/bin/public-inbox-init -V2 \
                      ${escapeShellArgs (
                        [
                          name
                          inbox.inboxdir
                          inbox.url
                        ]
                        ++ inbox.address
                      )}

                    rm -rf $conf_dir
                  fi

                  ln -sf ${inbox.description} \
                    ${escapeShellArg inbox.inboxdir}/description

                  export GIT_DIR=${escapeShellArg inbox.inboxdir}/all.git
                  if test -d "$GIT_DIR"; then
                    # Config is inherited by each epoch repository,
                    # so just needs to be set for all.git.
                    ${pkgs.git}/bin/git config core.sharedRepository 0640
                  fi
                '') cfg.inboxes
              );

              serviceConfig = {
                RemainAfterExit = true;

                StateDirectory = [
                  "public-inbox/.public-inbox"
                  "public-inbox/.public-inbox/emergency"
                  "public-inbox/inboxes"
                ];

                Type = "oneshot";
              };

              wantedBy = [ "multi-user.target" ];
            }
          ];
      }
    ];

    systemd.sockets = mkMerge (
      map
        (
          proto:
          mkIf (cfg.${proto}.enable && cfg.${proto}.port != null) {
            "public-inbox-${proto}d" = {
              listenStreams = [ (toString cfg.${proto}.port) ];
              wantedBy = [ "sockets.target" ];
            };
          }
        )
        [
          "imap"
          "http"
          "nntp"
        ]
    );

    users = {
      groups.public-inbox = { };

      users.public-inbox = {
        group = "public-inbox";
        home = stateDir;
        isSystemUser = true;
      };
    };
  };

  meta.maintainers = with lib.maintainers; [
    julm
    qyliss
  ];
}
