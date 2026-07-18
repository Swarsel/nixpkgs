{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.stunnel;

  verifyRequiredField = type: field: n: c: {
    assertion = lib.hasAttr field c;
    message = "stunnel: \"${n}\" ${type} configuration - Field ${field} is required.";
  };

  verifyChainPathAssert = n: c: {
    assertion = (c.verifyHostname or null) == null || (c.verifyChain || c.verifyPeer);

    message =
      "stunnel: \"${n}\" client configuration - hostname verification "
      + "is not possible without either verifyChain or verifyPeer enabled";
  };

  removeNulls = lib.mapAttrs (_: lib.filterAttrs (_: v: v != null));
  mkValueString =
    v: if lib.isBool v then lib.boolToYesNo v else lib.generators.mkValueStringDefault { } v;
  generateConfig =
    c:
    lib.generators.toINI {
      mkKeyValue = k: v: "${k} = ${mkValueString v}";
      mkSectionName = lib.id;
    } (removeNulls c);

in

{

  ###### interface

  options = {

    services.stunnel = {

      enable = lib.mkOption {
        default = false;
        description = "Whether to enable the stunnel TLS tunneling service.";
        type = lib.types.bool;
      };

      clients = lib.mkOption {
        apply =
          let
            applyDefaults =
              c:
              {
                CAFile = config.security.pki.caBundle;
                OCSPaia = true;
                verifyChain = true;
              }
              // c;
            setCheckHostFromVerifyHostname =
              c:
              # To preserve backward-compatibility with the old NixOS stunnel module
              # definition, allow "verifyHostname" as an alias for "checkHost".
              c
              // {
                checkHost = c.checkHost or c.verifyHostname or null;
                verifyHostname = null; # Not a real stunnel configuration setting
              };
            forceClient = c: c // { client = true; };
          in
          lib.mapAttrs (_: c: forceClient (setCheckHostFromVerifyHostname (applyDefaults c)));

        default = { };

        description = ''
          Define the client configurations.

          By default, verifyChain and OCSPaia are enabled and CAFile is set to `security.pki.caBundle`.

          See "SERVICE-LEVEL OPTIONS" in {manpage}`stunnel(8)`.
        '';

        example = {
          foobar = {
            accept = "0.0.0.0:8080";
            connect = "nixos.org:443";
            verifyChain = false;
          };
        };

        type =
          with lib.types;
          attrsOf (
            attrsOf (
              nullOr (oneOf [
                bool
                int
                str
              ])
            )
          );
      };

      enableInsecureSSLv3 = lib.mkOption {
        default = false;
        description = "Enable support for the insecure SSLv3 protocol.";
        type = lib.types.bool;
      };

      fipsMode = lib.mkOption {
        default = false;
        description = "Enable FIPS 140-2 mode required for compliance.";
        type = lib.types.bool;
      };

      group = lib.mkOption {
        default = "nogroup";
        description = "The group under which stunnel runs.";
        type = with lib.types; nullOr str;
      };

      logLevel = lib.mkOption {
        default = "info";
        description = "Verbosity of stunnel output.";

        type = lib.types.enum [
          "emerg"
          "alert"
          "crit"
          "err"
          "warning"
          "notice"
          "info"
          "debug"
        ];
      };

      servers = lib.mkOption {
        default = { };

        description = ''
          Define the server configurations.

          See "SERVICE-LEVEL OPTIONS" in {manpage}`stunnel(8)`.
        '';

        example = {
          fancyWebserver = {
            accept = 443;
            cert = "/path/to/pem/file";
            connect = 8080;
          };
        };

        type =
          with lib.types;
          attrsOf (
            attrsOf (
              nullOr (oneOf [
                bool
                int
                str
              ])
            )
          );
      };

      user = lib.mkOption {
        default = "nobody";
        description = "The user under which stunnel runs.";
        type = with lib.types; nullOr str;
      };
    };
  };

  ###### implementation

  config = lib.mkIf cfg.enable {

    assertions = lib.concatLists [
      (lib.singleton {
        assertion =
          (lib.length (lib.attrValues cfg.servers) != 0) || ((lib.length (lib.attrValues cfg.clients)) != 0);

        message = "stunnel: At least one server- or client-configuration has to be present.";
      })

      (lib.mapAttrsToList verifyChainPathAssert cfg.clients)
      (lib.mapAttrsToList (verifyRequiredField "client" "accept") cfg.clients)
      (lib.mapAttrsToList (verifyRequiredField "client" "connect") cfg.clients)
      (lib.mapAttrsToList (verifyRequiredField "server" "accept") cfg.servers)
      (lib.mapAttrsToList (verifyRequiredField "server" "cert") cfg.servers)
      (lib.mapAttrsToList (verifyRequiredField "server" "connect") cfg.servers)
    ];

    environment.etc."stunnel.cfg".text = ''
      ${lib.optionalString (cfg.user != null) "setuid = ${cfg.user}"}
      ${lib.optionalString (cfg.group != null) "setgid = ${cfg.group}"}

      debug = ${cfg.logLevel}

      ${lib.optionalString cfg.fipsMode "fips = yes"}
      ${lib.optionalString cfg.enableInsecureSSLv3 "options = -NO_SSLv3"}

      ; ----- SERVER CONFIGURATIONS -----
      ${generateConfig cfg.servers}

      ; ----- CLIENT CONFIGURATIONS -----
      ${generateConfig cfg.clients}
    '';

    environment.systemPackages = [ pkgs.stunnel ];

    systemd.services.stunnel = {
      after = [ "network.target" ];
      description = "stunnel TLS tunneling service";
      restartTriggers = [ config.environment.etc."stunnel.cfg".source ];

      serviceConfig = {
        ExecStart = "${pkgs.stunnel}/bin/stunnel ${config.environment.etc."stunnel.cfg".source}";
        Type = "forking";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [
    # Server side: maintainers wanted
    # Client side
    das_j
  ];

}
