{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let

  cfg = config.services.privoxy;

  serialise =
    name: val:
    if isList val then
      concatMapStrings (serialise name) val
    else if isBool val then
      serialise name (if val then "1" else "0")
    else
      "${name} ${toString val}\n";

  configType =
    with types;
    let
      atom = oneOf [
        int
        bool
        str
        path
      ];
    in
    attrsOf (either atom (listOf atom))
    // {
      description = ''
        privoxy configuration type. The format consists of an attribute
        set of settings. Each setting can be either a value (integer, string,
        boolean or path) or a list of such values.
      '';
    };

  ageType = types.str // {
    check = x: isString x && (builtins.match "([0-9]+([smhdw]|min|ms|us)*)+" x != null);
    description = "tmpfiles.d(5) age format";
  };

  configFile = pkgs.writeText "privoxy.conf" (
    concatStrings (
      # Relative paths in some options are relative to confdir. Privoxy seems
      # to parse the options in order of appearance, so this must come first.
      # Nix however doesn't preserve the order in attrsets, so we have to
      # hardcode confdir here.
      [ "confdir ${pkgs.privoxy}/etc\n" ] ++ mapAttrsToList serialise cfg.settings
    )
  );

  inspectAction = pkgs.writeText "inspect-all-https.action" ''
    # Enable HTTPS inspection for all requests
    {+https-inspection}
    /
  '';

in

{

  imports =
    let
      top = x: [
        "services"
        "privoxy"
        x
      ];
      setting = x: [
        "services"
        "privoxy"
        "settings"
        x
      ];
    in
    [
      (mkRenamedOptionModule (top "enableEditActions") (setting "enable-edit-actions"))
      (mkRenamedOptionModule (top "listenAddress") (setting "listen-address"))
      (mkRenamedOptionModule (top "actionsFiles") (setting "actionsfile"))
      (mkRenamedOptionModule (top "filterFiles") (setting "filterfile"))
      (mkRemovedOptionModule (top "extraConfig") ''
        Use services.privoxy.settings instead.
        This is part of the general move to use structured settings instead of raw
        text for config as introduced by RFC0042:
        https://github.com/NixOS/rfcs/blob/master/rfcs/0042-config-option.md
      '')
    ];

  ###### interface
  options.services.privoxy = {

    enable = mkEnableOption "Privoxy, non-caching filtering proxy";

    certsLifetime = mkOption {
      default = "10d";

      description = ''
        If `inspectHttps` is enabled, the time generated HTTPS
        certificates will be stored in a temporary directory for reuse. Once
        the lifetime has expired the directory will cleared and the certificate
        will have to be generated again, on-demand.

        Depending on the traffic, you may want to reduce the lifetime to limit
        the disk usage, since Privoxy itself never deletes the certificates.

        ::: {.note}
        The format is that of the {manpage}`tmpfiles.d(5)`
        Age parameter.
        :::
      '';

      example = "12h";
      type = ageType;
    };

    enableTor = mkOption {
      default = false;

      description = ''
        Whether to configure Privoxy to use Tor's faster SOCKS port,
        suitable for HTTP.
      '';

      type = types.bool;
    };

    inspectHttps = mkOption {
      default = false;

      description = ''
        Whether to configure Privoxy to inspect HTTPS requests, meaning all
        encrypted traffic will be filtered as well. This works by decrypting
        and re-encrypting the requests using a per-domain generated certificate.

        To issue per-domain certificates, Privoxy must be provided with a CA
        certificate, using the `ca-cert-file`,
        `ca-key-file` settings.

        ::: {.warning}
        The CA certificate must also be added to the system trust roots,
        otherwise browsers will reject all Privoxy certificates as invalid.
        You can do so by using the option
        {option}`security.pki.certificateFiles`.
        :::
      '';

      type = types.bool;
    };

    settings = mkOption {
      default = { };

      description = ''
        This option is mapped to the main Privoxy configuration file.
        Check out the Privoxy user manual at
        <https://www.privoxy.org/user-manual/config.html>
        for available settings and documentation.

        ::: {.note}
        Repeated settings can be represented by using a list.
        :::
      '';

      example = literalExpression ''
        { # Listen on IPv6 only
          listen-address = "[::]:8118";

          # Forward .onion requests to Tor
          forward-socks5 = ".onion localhost:9050 .";

          # Log redirects and filters
          debug = [ 128 64 ];
          # This is equivalent to writing these lines
          # in the Privoxy configuration file:
          # debug 128
          # debug 64
        }
      '';

      type = types.submodule {
        options.actionsfile = mkOption {
          # This must come after all other entries, in order to override the
          # other actions/filters installed by Privoxy or the user.
          apply =
            x: x ++ optional (cfg.userActions != "") (toString (pkgs.writeText "user.actions" cfg.userActions));

          default = [
            "match-all.action"
            "default.action"
          ];

          description = ''
            List of paths to Privoxy action files. These paths may either be
            absolute or relative to the privoxy configuration directory.
          '';

          type = types.listOf types.str;
        };

        options.enable-edit-actions = mkOption {
          default = false;
          description = "Whether the web-based actions file editor may be used.";
          type = types.bool;
        };

        options.filterfile = mkOption {
          apply =
            x: x ++ optional (cfg.userFilters != "") (toString (pkgs.writeText "user.filter" cfg.userFilters));

          default = [ "default.filter" ];

          description = ''
            List of paths to Privoxy filter files. These paths may either be
            absolute or relative to the privoxy configuration directory.
          '';

          type = types.listOf types.str;
        };

        options.listen-address = mkOption {
          default = "127.0.0.1:8118";
          description = "Pair of address:port the proxy server is listening to.";
          type = types.either types.str (types.listOf types.str);
        };

        freeformType = configType;
      };
    };

    userActions = mkOption {
      default = "";

      description = ''
        Actions to be included in a `user.action` file. This
        will have a higher priority and can be used to override all other
        actions.
      '';

      type = types.lines;
    };

    userFilters = mkOption {
      default = "";

      description = ''
        Filters to be included in a `user.filter` file. This
        will have a higher priority and can be used to override all other
        filters definitions.
      '';

      type = types.lines;
    };

  };

  ###### implementation
  config = mkIf cfg.enable {

    services.privoxy.settings = {
      actionsfile = [
        "match-all.action"
        "default.action"
      ]
      ++ optional cfg.inspectHttps (toString inspectAction);

      filterfile = [ "default.filter" ];
      # This is needed for external filters
      temporary-directory = "/tmp";
      user-manual = "${pkgs.privoxy}/share/doc/privoxy/user-manual";
    }
    // (optionalAttrs cfg.enableTor {
      enable-edit-actions = false;
      enable-remote-http-toggle = false;
      enable-remote-toggle = false;
      forward-socks5 = "/ 127.0.0.1:9063 .";
      toggle = true;
    })
    // (optionalAttrs cfg.inspectHttps {
      # This allows setting absolute key/crt paths
      ca-directory = "/var/empty";
      certificate-directory = "/run/privoxy/certs";
      trusted-cas-file = config.security.pki.caBundle;
    });

    services.tor.settings.SOCKSPort = mkIf cfg.enableTor [
      # Route HTTP traffic over a faster port (without IsolateDestAddr).
      {
        IsolateDestAddr = false;
        addr = "127.0.0.1";
        port = 9063;
      }
    ];

    systemd.services.privoxy = {
      after = [
        "network.target"
        "nss-lookup.target"
      ];

      description = "Filtering web proxy";
      documentation = [ "man:privoxy(8)" ];

      serviceConfig = {
        ExecStart = "${pkgs.privoxy}/bin/privoxy --no-daemon ${configFile}";
        Group = "privoxy";
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "full";
        User = "privoxy";
      };

      unitConfig = mkIf cfg.inspectHttps {
        ConditionPathExists = with cfg.settings; [
          ca-cert-file
          ca-key-file
        ];
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.rules = optional cfg.inspectHttps "d ${cfg.settings.certificate-directory} 0770 privoxy privoxy ${cfg.certsLifetime}";
    users.groups.privoxy = { };

    users.users.privoxy = {
      description = "Privoxy daemon user";
      group = "privoxy";
      isSystemUser = true;
    };
  };

  meta.maintainers = with lib.maintainers; [ rnhmjoj ];

}
