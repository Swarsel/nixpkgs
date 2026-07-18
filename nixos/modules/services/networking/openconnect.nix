{
  config,
  lib,
  pkgs,
  options,
  ...
}:
with lib;
let
  cfg = config.networking.openconnect;
  openconnect = cfg.package;
  pkcs11 = types.strMatching "pkcs11:.+" // {
    description = "PKCS#11 URI";
    name = "pkcs11";
  };
  interfaceOptions = {
    options = {
      autoStart = mkOption {
        default = true;
        description = "Whether this VPN connection should be started automatically.";
        type = types.bool;
      };

      certificate = mkOption {
        default = null;
        description = "Certificate to authenticate with.";
        example = "/var/lib/secrets/openconnect_certificate.pem";
        type = with types; nullOr (either path pkcs11);
      };

      extraOptions = mkOption {
        default = { };

        description = ''
          Extra config to be appended to the interface config. It should
          contain long-format options as would be accepted on the command
          line by `openconnect`
          (see <https://www.infradead.org/openconnect/manual.html>).
          Non-key-value options like `deflate` can be used by
          declaring them as booleans, i. e. `deflate = true;`.
        '';

        example = {
          compression = "stateless";
          no-dtls = true;
          no-http-keepalive = true;
        };

        type = with types; attrsOf (either str bool);
      };

      gateway = mkOption {
        description = "Gateway server to connect to.";
        example = "gateway.example.com";
        type = types.str;
      };

      # Note: It does not make sense to provide a way to declaratively
      # set an authentication cookie, because they have to be requested
      # for every new connection and would only work once.
      passwordFile = mkOption {
        default = null;

        description = ''
          File containing the password to authenticate with. This
          is passed to `openconnect` via the
          `--passwd-on-stdin` option.
        '';

        example = "/var/lib/secrets/openconnect-passwd";
        type = types.nullOr types.path;
      };

      privateKey = mkOption {
        default = null;
        description = "Private key to authenticate with.";
        example = "/var/lib/secrets/openconnect_private_key.pem";
        type = with types; nullOr (either path pkcs11);
      };

      protocol = mkOption {
        description = "Protocol to use.";
        example = "anyconnect";

        type = types.enum [
          "anyconnect"
          "array"
          "nc"
          "pulse"
          "gp"
          "f5"
          "fortinet"
        ];
      };

      user = mkOption {
        default = null;
        description = "Username to authenticate with.";
        example = "example-user";
        type = types.nullOr types.str;
      };
    };
  };
  generateExtraConfig =
    extra_cfg:
    strings.concatStringsSep "\n" (
      attrsets.mapAttrsToList (name: value: if (value == true) then name else "${name}=${value}") (
        attrsets.filterAttrs (_: value: value != false) extra_cfg
      )
    );
  generateConfig =
    name: icfg:
    pkgs.writeText "config" ''
      interface=${name}
      ${optionalString (icfg.protocol != null) "protocol=${icfg.protocol}"}
      ${optionalString (icfg.user != null) "user=${icfg.user}"}
      ${optionalString (icfg.passwordFile != null) "passwd-on-stdin"}
      ${optionalString (icfg.certificate != null) "certificate=${icfg.certificate}"}
      ${optionalString (icfg.privateKey != null) "sslkey=${icfg.privateKey}"}

      ${generateExtraConfig icfg.extraOptions}
    '';
  generateUnit = name: icfg: {
    after = [
      "network.target"
      "network-online.target"
    ];

    description = "OpenConnect Interface - ${name}";
    requires = [ "network-online.target" ];

    serviceConfig = {
      ExecStart = "${openconnect}/bin/openconnect --config=${generateConfig name icfg} ${icfg.gateway}";
      ProtectHome = true;
      StandardInput = lib.mkIf (icfg.passwordFile != null) "file:${icfg.passwordFile}";
      Type = "simple";
    };

    wantedBy = optional icfg.autoStart "multi-user.target";
  };
in
{
  options.networking.openconnect = {
    package = mkPackageOption pkgs "openconnect" { };

    interfaces = mkOption {
      default = { };
      description = "OpenConnect interfaces.";

      example = {
        openconnect0 = {
          gateway = "gateway.example.com";
          passwordFile = "/var/lib/secrets/openconnect-passwd";
          protocol = "anyconnect";
          user = "example-user";
        };
      };

      type = with types; attrsOf (submodule interfaceOptions);
    };
  };

  config = {
    systemd.services = mapAttrs' (name: value: {
      name = "openconnect-${name}";
      value = generateUnit name value;
    }) cfg.interfaces;
  };

  meta.maintainers = with maintainers; [ pentane ];
}
