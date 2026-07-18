{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.services.prosody;
  communityModulesToEnable =
    let
      componentSpecificModules = [ "muc_notifications" ];
    in
    lib.concatMap (
      mod: lib.optional (!(lib.elem mod componentSpecificModules)) "${toLua mod};"
    ) cfg.package.communityModules;

  sslOpts = _: {
    options = {
      # TODO: rename to certificate to match the prosody config
      cert = mkOption {
        description = "Path to the certificate file.";
        type = types.path;
      };

      extraOptions = mkOption {
        default = { };
        description = "Extra SSL configuration options.";
        type = types.attrs;
      };

      key = mkOption {
        description = "Path to the key file.";
        type = types.path;
      };
    };
  };

  discoOpts = {
    options = {
      description = mkOption {
        description = "A short description of the endpoint you want to advertise";
        type = types.str;
      };

      url = mkOption {
        description = "URL of the endpoint you want to make discoverable";
        type = types.str;
      };
    };
  };

  moduleOpts = {
    # Admin interfaces
    admin_adhoc = mkOption {
      default = true;
      description = "Allows administration via an XMPP client that supports ad-hoc commands";
      type = types.bool;
    };

    admin_telnet = mkOption {
      default = false;
      description = "Opens telnet console interface on localhost port 5582";
      type = types.bool;
    };

    announce = mkOption {
      default = false;
      description = "Send announcement to all online users";
      type = types.bool;
    };

    blocklist = mkOption {
      default = true;
      description = "Allow users to block communications with other users";
      type = types.bool;
    };

    bookmarks = mkOption {
      default = true;
      description = "Allows interop between older clients that use XEP-0048: Bookmarks in its 1.0 version and recent clients which use it in PEP";
      type = types.bool;
    };

    # HTTP modules
    bosh = mkOption {
      default = false;
      description = "Enable BOSH clients, aka 'Jabber over HTTP'";
      type = types.bool;
    };

    # Not essential, but recommended
    carbons = mkOption {
      default = true;
      description = "Keep multiple clients in sync";
      type = types.bool;
    };

    cloud_notify = mkOption {
      default = true;
      description = "Push notifications to inform users of new messages or other pertinent information even when they have no XMPP clients online";
      type = types.bool;
    };

    csi = mkOption {
      default = true;
      description = "Implements the CSI protocol that allows clients to report their active/inactive state to the server";
      type = types.bool;
    };

    dialback = mkOption {
      default = true;
      description = "s2s dialback support";
      type = types.bool;
    };

    disco = mkOption {
      default = true;
      description = "Service discovery";
      type = types.bool;
    };

    groups = mkOption {
      default = false;
      description = "Shared roster support";
      type = types.bool;
    };

    http_files = mkOption {
      default = false;
      description = "Serve static files from a directory over HTTP";
      type = types.bool;
    };

    legacyauth = mkOption {
      default = false;
      description = "Legacy authentication. Only used by some old clients and bots";
      type = types.bool;
    };

    # Other specific functionality
    limits = mkOption {
      default = false;
      description = "Enable bandwidth limiting for XMPP connections";
      type = types.bool;
    };

    mam = mkOption {
      default = true;
      description = "Store messages in an archive and allow users to access it";
      type = types.bool;
    };

    motd = mkOption {
      default = false;
      description = "Send a message to users when they log in";
      type = types.bool;
    };

    pep = mkOption {
      default = true;
      description = "Enables users to publish their mood, activity, playing music and more";
      type = types.bool;
    };

    ping = mkOption {
      default = true;
      description = "Replies to XMPP pings with pongs";
      type = types.bool;
    };

    private = mkOption {
      default = true;
      description = "Private XML storage (for room bookmarks, etc.)";
      type = types.bool;
    };

    proxy65 = mkOption {
      default = true;
      description = "Enables a file transfer proxy service which clients behind NAT can use";
      type = types.bool;
    };

    register = mkOption {
      default = true;
      description = "Allow users to register on this server using a client and change passwords";
      type = types.bool;
    };

    # Required for compliance with https://compliance.conversations.im/about/
    roster = mkOption {
      default = true;
      description = "Allow users to have a roster";
      type = types.bool;
    };

    saslauth = mkOption {
      default = true;
      description = "Authentication for clients and servers. Recommended if you want to log in.";
      type = types.bool;
    };

    server_contact_info = mkOption {
      default = false;
      description = "Publish contact information for this service";
      type = types.bool;
    };

    smacks = mkOption {
      default = true;
      description = "Allow a client to resume a disconnected session, and prevent message loss";
      type = types.bool;
    };

    time = mkOption {
      default = true;
      description = "Let others know the time here on this server";
      type = types.bool;
    };

    tls = mkOption {
      default = true;
      description = "Add support for secure TLS on c2s/s2s connections";
      type = types.bool;
    };

    uptime = mkOption {
      default = true;
      description = "Report how long server has been running";
      type = types.bool;
    };

    vcard = mkOption {
      default = false;
      description = "Allow users to set vCards";
      type = types.bool;
    };

    vcard_legacy = mkOption {
      default = true;
      description = "Converts users profiles and Avatars between old and new formats";
      type = types.bool;
    };

    # Nice to have
    version = mkOption {
      default = true;
      description = "Replies to server version requests";
      type = types.bool;
    };

    watchregistrations = mkOption {
      default = false;
      description = "Alert admins of registrations";
      type = types.bool;
    };

    websocket = mkOption {
      default = false;
      description = "Enable WebSocket support";
      type = types.bool;
    };

    welcome = mkOption {
      default = false;
      description = "Welcome users who register accounts";
      type = types.bool;
    };
  };

  toLua =
    x:
    if builtins.isString x then
      ''"${x}"''
    else if builtins.isBool x then
      boolToString x
    else if builtins.isInt x then
      toString x
    else if builtins.isList x then
      "{ ${lib.concatMapStringsSep ", " toLua x} }"
    else
      throw "Invalid Lua value";

  settingsToLua =
    prefix: settings:
    generators.toKeyValue {
      listsAsDuplicateKeys = false;

      mkKeyValue =
        k:
        generators.mkKeyValueDefault {
          mkValueString = toLua;
        } " = " (prefix + k);
    } (filterAttrs (k: v: v != null) settings);

  createSSLOptsStr = o: ''
    ssl = {
      cafile = "/etc/ssl/certs/ca-bundle.crt";
      key = "${o.key}";
      certificate = "${o.cert}";
      ${concatStringsSep "\n" (
        mapAttrsToList (name: value: "${name} = ${toLua value};") o.extraOptions
      )}
    };
  '';

  mucOpts = _: {
    options = {
      allowners_muc = mkOption {
        default = false;

        description = ''
          Add module allowners, any user in chat is able to
          kick other. Useful in jitsi-meet to kick ghosts.
        '';

        type = types.bool;
      };

      domain = mkOption {
        description = "Domain name of the MUC";
        type = types.str;
      };

      extraConfig = mkOption {
        default = "";
        description = "Additional MUC specific configuration";
        type = types.lines;
      };

      maxHistoryMessages = mkOption {
        default = 20;
        description = "Specifies a limit on what each room can be configured to keep";
        type = types.int;
      };

      moderation = mkOption {
        default = false;
        description = "Allow rooms to be moderated";
        type = types.bool;
      };

      name = mkOption {
        default = "Prosody Chatrooms";
        description = "The name to return in service discovery responses for the MUC service itself";
        type = types.str;
      };

      restrictRoomCreation = mkOption {
        default = false;
        description = "Restrict room creation to server admins";

        type = types.enum [
          true
          false
          "admin"
          "local"
        ];
      };

      roomDefaultChangeSubject = mkOption {
        default = false;
        description = "If set, the rooms will display the public JIDs by default.";
        type = types.bool;
      };

      roomDefaultHistoryLength = mkOption {
        default = 20;
        description = "Number of history message sent to participants by default.";
        type = types.int;
      };

      roomDefaultLanguage = mkOption {
        default = "en";
        description = "Default room language.";
        type = types.str;
      };

      roomDefaultMembersOnly = mkOption {
        default = false;
        description = "If set, the MUC rooms will only be accessible to the members by default.";
        type = types.bool;
      };

      roomDefaultModerated = mkOption {
        default = false;
        description = "If set, the MUC rooms will be moderated by default.";
        type = types.bool;
      };

      # Extra parameters. Defaulting to prosody default values.
      # Adding them explicitly to make them visible from the options
      # documentation.
      #
      # See https://prosody.im/doc/modules/mod_muc for more details.
      roomDefaultPublic = mkOption {
        default = true;
        description = "If set, the MUC rooms will be public by default.";
        type = types.bool;
      };

      roomDefaultPublicJids = mkOption {
        default = false;
        description = "If set, the MUC rooms will display the public JIDs by default.";
        type = types.bool;
      };

      roomLockTimeout = mkOption {
        default = 300;

        description = ''
          Timeout after which the room is destroyed or unlocked if not
          configured, in seconds
        '';

        type = types.int;
      };

      roomLocking = mkOption {
        default = true;

        description = ''
          Enables room locking, which means that a room must be
          configured before it can be used. Locked rooms are invisible
          and cannot be entered by anyone but the creator
        '';

        type = types.bool;
      };

      tombstoneExpiry = mkOption {
        default = 2678400;

        description = ''
          This settings controls how long a tombstone is considered
          valid. It defaults to 31 days. After this time, the room in
          question can be created again.
        '';

        type = types.int;
      };

      tombstones = mkOption {
        default = true;

        description = ''
          When a room is destroyed, it leaves behind a tombstone which
          prevents the room being entered or recreated. It also allows
          anyone who was not in the room at the time it was destroyed
          to learn about it, and to update their bookmarks. Tombstones
          prevents the case where someone could recreate a previously
          semi-anonymous room in order to learn the real JIDs of those
          who often join there.
        '';

        type = types.bool;
      };
    };
  };

  httpFileShareOpts =
    { config, options, ... }:
    {
      options = {
        daily_quota = mkOption {
          default = 10 * config.size_limit;
          defaultText = lib.literalExpression "10 * ${options.size_limit}";

          description = ''
            Maximum size of daily uploaded files per user, in bytes.
          '';

          example = "100*1024*1024";
          type = types.nullOr types.int;
        };

        domain = mkOption {
          description = "Domain name for a http_file_share service.";
          type = with types; nullOr str;
        };

        expires_after = mkOption {
          default = "1 week";
          description = "Max age of a file before it gets deleted.";
          type = types.str;
        };

        http_external_url = mkOption {
          default = null;
          description = "External URL in case Prosody sits behind a reverse proxy.";
          type = types.nullOr types.str;
        };

        http_host = mkOption {
          default = null;

          description = ''
            To avoid an additional DNS record and certificate, you may set this option to your primary domain (e.g. "example.com")
            or use a reverse proxy to handle the HTTP for that domain.
          '';

          type = types.nullOr types.str;
        };

        size_limit = mkOption {
          default = 10 * 1024 * 1024;
          defaultText = "10 * 1024 * 1024";
          description = "Maximum file size, in bytes.";
          type = types.int;
        };
      };

      freeformType =
        with types;
        let
          atom = oneOf [
            int
            bool
            str
            (listOf atom)
          ];
        in
        attrsOf (nullOr atom)
        // {
          description = "int, bool, string or list of them";
        };
    };

  vHostOpts = _: {
    options = {
      # TODO: require attribute
      domain = mkOption {
        description = "Domain name";
        type = types.str;
      };

      enabled = mkOption {
        default = false;
        description = "Whether to enable the virtual host";
        type = types.bool;
      };

      extraConfig = mkOption {
        default = "";
        description = "Additional virtual host specific configuration";
        type = types.lines;
      };

      ssl = mkOption {
        default = null;
        description = "Paths to SSL files";
        type = types.nullOr (types.submodule sslOpts);
      };
    };
  };

  configFile =
    let
      httpDiscoItems = optional (cfg.httpFileShare != null) {
        description = "HTTP file share endpoint";
        url = cfg.httpFileShare.domain;
      };
      mucDiscoItems = builtins.foldl' (
        acc: muc:
        [
          {
            description = "${muc.domain} MUC endpoint";
            url = muc.domain;
          }
        ]
        ++ acc
      ) [ ] cfg.muc;
      discoItems = cfg.disco_items ++ httpDiscoItems ++ mucDiscoItems;
    in
    pkgs.writeText "prosody.cfg.lua" ''
      pidfile = "/run/prosody/prosody.pid"

      log = ${cfg.log}

      data_path = "${cfg.dataDir}"
      plugin_paths = {
        ${lib.concatStringsSep ", " (map (n: "\"${n}\"") cfg.extraPluginPaths)}
      }

      ${optionalString (cfg.ssl != null) (createSSLOptsStr cfg.ssl)}

      admins = ${toLua cfg.admins}

      modules_enabled = {
        "admin_shell";  -- for prosodyctl
        ${lib.concatStringsSep "\n  " (
          lib.mapAttrsToList (name: val: optionalString val "${toLua name};") cfg.modules
        )}
        ${lib.concatStringsSep "\n" communityModulesToEnable}
        ${lib.concatStringsSep "\n" (map (x: "${toLua x};") cfg.extraModules)}
      };

      disco_items = {
      ${lib.concatStringsSep "\n" (map (x: ''{ "${x.url}", "${x.description}"};'') discoItems)}
      };

      allow_registration = ${toLua cfg.allowRegistration}

      c2s_require_encryption = ${toLua cfg.c2sRequireEncryption}

      s2s_require_encryption = ${toLua cfg.s2sRequireEncryption}
      s2s_secure_auth = ${toLua cfg.s2sSecureAuth}
      s2s_insecure_domains = ${toLua cfg.s2sInsecureDomains}
      s2s_secure_domains = ${toLua cfg.s2sSecureDomains}

      authentication = ${toLua cfg.authentication}

      http_interfaces = ${toLua cfg.httpInterfaces}
      https_interfaces = ${toLua cfg.httpsInterfaces}

      http_ports = ${toLua cfg.httpPorts}
      https_ports = ${toLua cfg.httpsPorts}

      mime_types_file = "${pkgs.mailcap}/etc/mime.types"

      ${cfg.extraConfig}

      ${lib.concatMapStrings (muc: ''
        Component ${toLua muc.domain} "muc"
            modules_enabled = {${optionalString cfg.modules.mam ''"muc_mam",''}${optionalString muc.allowners_muc ''"muc_allowners",''}${optionalString muc.moderation ''"muc_moderation",''}${optionalString (lib.elem "muc_notifications" cfg.package.communityModules) ''"muc_notifications",''} }
            name = ${toLua muc.name}
            restrict_room_creation = ${toLua muc.restrictRoomCreation}
            max_history_messages = ${toLua muc.maxHistoryMessages}
            muc_room_locking = ${toLua muc.roomLocking}
            muc_room_lock_timeout = ${toLua muc.roomLockTimeout}
            muc_tombstones = ${toLua muc.tombstones}
            muc_tombstone_expiry = ${toLua muc.tombstoneExpiry}
            muc_room_default_public = ${toLua muc.roomDefaultPublic}
            muc_room_default_members_only = ${toLua muc.roomDefaultMembersOnly}
            muc_room_default_moderated = ${toLua muc.roomDefaultModerated}
            muc_room_default_public_jids = ${toLua muc.roomDefaultPublicJids}
            muc_room_default_change_subject = ${toLua muc.roomDefaultChangeSubject}
            muc_room_default_history_length = ${toLua muc.roomDefaultHistoryLength}
            muc_room_default_language = ${toLua muc.roomDefaultLanguage}
            ${muc.extraConfig}
      '') cfg.muc}

      ${lib.optionalString (cfg.httpFileShare != null) ''
        Component ${toLua cfg.httpFileShare.domain} "http_file_share"
          modules_disabled = { "s2s" }
        ${lib.optionalString (cfg.httpFileShare.http_host != null) ''
          http_host = "${cfg.httpFileShare.http_host}"
        ''}
        ${lib.optionalString (cfg.httpFileShare.http_external_url != null) ''
          http_external_url = "${cfg.httpFileShare.http_external_url}"
        ''}
        ${settingsToLua "  http_file_share_" (
          cfg.httpFileShare
          // {
            domain = null;
            http_external_url = null;
            http_host = null;
          }
        )}
      ''}

      ${lib.concatStringsSep "\n" (
        lib.mapAttrsToList (n: v: ''
          VirtualHost "${v.domain}"
            enabled = ${boolToString v.enabled};
            ${optionalString (v.ssl != null) (createSSLOptsStr v.ssl)}
            ${v.extraConfig}
        '') cfg.virtualHosts
      )}
    '';
in
{
  imports = [
    (lib.mkRemovedOptionModule [ "services" "prosody" "uploadHttp" ]
      "mod_http_upload has been obsoloted and been replaced by mod_http_file_share which can be configured with httpFileShare options."
    )
  ];

  options = {
    services.prosody = {
      enable = mkOption {
        default = false;
        description = "Whether to enable the prosody server";
        type = types.bool;
      };

      package = mkPackageOption pkgs "prosody" {
        example = ''
          pkgs.prosody.override {
            withExtraLibs = [ pkgs.luaPackages.lpty ];
            withCommunityModules = [ "auth_external" ];
          };
        '';
      };

      admins = mkOption {
        default = [ ];
        description = "List of administrators of the current host";

        example = [
          "admin1@example.com"
          "admin2@example.com"
        ];

        type = types.listOf types.str;
      };

      allowRegistration = mkOption {
        default = false;
        description = "Allow account creation";
        type = types.bool;
      };

      authentication = mkOption {
        default = "internal_hashed";
        description = "Authentication mechanism used for logins.";
        example = "internal_plain";

        type = types.enum [
          "internal_plain"
          "internal_hashed"
          "cyrus"
          "anonymous"
          "ldap"
        ];
      };

      c2sRequireEncryption = mkOption {
        default = true;

        description = ''
          Force clients to use encrypted connections? This option will
          prevent clients from authenticating unless they are using encryption.
        '';

        type = types.bool;
      };

      checkConfig = mkOption {
        default = true;
        description = "Check the configuration file with `prosodyctl check config`";
        example = false;
        type = types.bool;
      };

      dataDir = mkOption {
        default = "/var/lib/prosody";

        description = ''
          The prosody home directory used to store all data. If left as the default value
          this directory will automatically be created before the prosody server starts, otherwise
          you are responsible for ensuring the directory exists with appropriate ownership
          and permissions.
        '';

        type = types.path;
      };

      disco_items = mkOption {
        default = [ ];
        description = "List of discoverable items you want to advertise.";
        type = types.listOf (types.submodule discoOpts);
      };

      extraConfig = mkOption {
        default = "";

        description = ''
          Additional prosody configuration

          The generated file is processed by `envsubst` to allow secrets to be passed securely via environment variables.
        '';

        type = types.lines;
      };

      extraModules = mkOption {
        default = [ ];
        description = "Enable custom modules";
        type = types.listOf types.str;
      };

      extraPluginPaths = mkOption {
        default = [ ];
        description = "Additional path in which to look find plugins/modules";
        type = types.listOf types.path;
      };

      group = mkOption {
        default = "prosody";

        description = ''
          Group account under which prosody runs.

          ::: {.note}
          If left as the default value this group will automatically be created
          on system activation, otherwise you are responsible for
          ensuring the group exists before the prosody service starts.
          :::
        '';

        type = types.str;
      };

      httpFileShare = mkOption {
        default = null;

        description = ''
          Configures the http_file_share module to handle user uploads.

          See <https://prosody.im/doc/modules/mod_http_file_share> for a full list of options.
        '';

        example = {
          domain = "uploads.my-xmpp-example-host.org";
        };

        type = types.nullOr (types.submodule httpFileShareOpts);
      };

      httpInterfaces = mkOption {
        default = [
          "*"
          "::"
        ];

        description = "Interfaces on which the HTTP server will listen on.";
        type = types.listOf types.str;
      };

      # HTTP server-related options
      httpPorts = mkOption {
        default = [ 5280 ];
        description = "Listening HTTP ports list for this service.";
        type = types.listOf types.port;
      };

      httpsInterfaces = mkOption {
        default = [
          "*"
          "::"
        ];

        description = "Interfaces on which the HTTPS server will listen on.";
        type = types.listOf types.str;
      };

      httpsPorts = mkOption {
        default = [ 5281 ];
        description = "Listening HTTPS ports list for this service.";
        type = types.listOf types.port;
      };

      log = mkOption {
        default = ''"*syslog"'';
        description = "Logging configuration. See [](https://prosody.im/doc/logging) for more details";

        example = ''
          {
            { min = "warn"; to = "*syslog"; };
          }
        '';

        type = types.lines;
      };

      modules = moduleOpts;

      muc = mkOption {
        default = [ ];
        description = "Multi User Chat (MUC) configuration";

        example = [
          {
            domain = "conference.my-xmpp-example-host.org";
          }
        ];

        type = types.listOf (types.submodule mucOpts);
      };

      s2sInsecureDomains = mkOption {
        default = [ ];

        description = ''
          Some servers have invalid or self-signed certificates. You can list
          remote domains here that will not be required to authenticate using
          certificates. They will be authenticated using DNS instead, even
          when s2s_secure_auth is enabled.
        '';

        example = [ "insecure.example.com" ];
        type = types.listOf types.str;
      };

      s2sRequireEncryption = mkOption {
        default = true;

        description = ''
          Force servers to use encrypted connections? This option will
          prevent servers from authenticating unless they are using encryption.
          Note that this is different from authentication.
        '';

        type = types.bool;
      };

      s2sSecureAuth = mkOption {
        default = false;

        description = ''
          Force certificate authentication for server-to-server connections?
          This provides ideal security, but requires servers you communicate
          with to support encryption AND present valid, trusted certificates.
          For more information see <https://prosody.im/doc/s2s#security>
        '';

        type = types.bool;
      };

      s2sSecureDomains = mkOption {
        default = [ ];

        description = ''
          Even if you leave s2s_secure_auth disabled, you can still require valid
          certificates for some domains by specifying a list here.
        '';

        example = [ "jabber.org" ];
        type = types.listOf types.str;
      };

      ssl = mkOption {
        default = null;
        description = "Paths to SSL files";
        type = types.nullOr (types.submodule sslOpts);
      };

      user = mkOption {
        default = "prosody";

        description = ''
          User account under which prosody runs.

          ::: {.note}
          If left as the default value this user will automatically be created
          on system activation, otherwise you are responsible for
          ensuring the user exists before the prosody service starts.
          :::
        '';

        type = types.str;
      };

      virtualHosts = mkOption {

        default = {
          localhost = {
            domain = "localhost";
            enabled = true;
          };
        };

        description = "Define the virtual hosts";

        example = {
          myhost = {
            domain = "my-xmpp-example-host.org";
            enabled = true;
          };
        };

        type = with types; attrsOf (submodule vHostOpts);

      };

      xmppComplianceSuite = mkOption {
        default = true;

        description = ''
          The XEP-0423 defines a set of recommended XEPs to implement
          for a server. It's generally a good idea to implement this
          set of extensions if you want to provide your users with a
          good XMPP experience.

          This NixOS module aims to provide a "advanced server"
          experience as per defined in the XEP-0423[1] specification.

          Setting this option to true will prevent you from building a
          NixOS configuration which won't comply with this standard.
          You can explicitly decide to ignore this standard if you
          know what you are doing by setting this option to false.

          [1] https://xmpp.org/extensions/xep-0423.html
        '';

        type = types.bool;
      };
    };
  };

  config = mkIf cfg.enable {
    assertions =
      let
        genericErrMsg = ''

          Having a server not XEP-0423-compliant might make your XMPP
          experience terrible. See the NixOS manual for further
          information.

          If you know what you're doing, you can disable this warning by
          setting config.services.prosody.xmppComplianceSuite to false.
        '';
        errors = [
          {
            assertion = (builtins.length cfg.muc > 0) || !cfg.xmppComplianceSuite;

            message = ''
              You need to setup at least a MUC domain to comply with
              XEP-0423.
            ''
            + genericErrMsg;
          }
          {
            assertion = cfg.httpFileShare != null || !cfg.xmppComplianceSuite;

            message = ''
              You need to setup http_file_share modules through config.services.prosody.httpFileShare to comply with XEP-0423.
            ''
            + genericErrMsg;
          }
        ];
      in
      errors;

    # prevent error if not all certs are configured by the user
    environment.etc."prosody/certs/.dummy".text = "";

    environment.etc."prosody/prosody.cfg.lua".source =
      if cfg.checkConfig then
        pkgs.runCommandLocal "prosody.cfg.lua"
          {
            nativeBuildInputs = [ cfg.package ];
          }
          ''
            cp ${configFile} prosody.cfg.lua
            # Replace the hardcoded path to cacerts with one that is accessible in the build sandbox
            sed 's|/etc/ssl/certs/ca-bundle.crt|${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt|' -i prosody.cfg.lua
            # For some reason prosody hard fails to "find" certificates when this directory does not exist
            mkdir certs
            prosodyctl --config ./prosody.cfg.lua check config
            cp prosody.cfg.lua $out
          ''
      else
        configFile;

    environment.systemPackages = [ cfg.package ];

    systemd.services.prosody = {
      after = [ "network-online.target" ];
      description = "Prosody XMPP server";

      preStart = ''
        ${pkgs.envsubst}/bin/envsubst -i ${
          config.environment.etc."prosody/prosody.cfg.lua".source
        } -o /run/prosody/prosody.cfg.lua
      '';

      restartTriggers = [ config.environment.etc."prosody/prosody.cfg.lua".source ];

      serviceConfig = mkMerge [
        {
          AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
          Environment = "PROSODY_CONFIG=/run/prosody/prosody.cfg.lua";
          ExecStart = "${lib.getExe cfg.package} -F";
          Group = cfg.group;
          MemoryDenyWriteExecute = true;
          PIDFile = "/run/prosody/prosody.pid";
          PrivateDevices = true;
          PrivateMounts = true;
          PrivateTmp = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectHostname = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          Restart = "on-abnormal";
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          RuntimeDirectory = "prosody";
          Type = "notify-reload";
          User = cfg.user;
        }
        (mkIf (cfg.dataDir == "/var/lib/prosody") {
          StateDirectory = "prosody";
        })
      ];

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };

    users.groups.prosody = mkIf (cfg.group == "prosody") {
      gid = config.ids.gids.prosody;
    };

    users.users.prosody = mkIf (cfg.user == "prosody") {
      inherit (cfg) group;
      description = "Prosody user";
      home = cfg.dataDir;
      uid = config.ids.uids.prosody;
    };
  };

  meta.doc = ./prosody.md;
}
