{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.dnsdist;

  toLua = lib.generators.toLua { };

  mkBind = cfg: toLua "${cfg.listenAddress}:${toString cfg.listenPort}";

  configFile = pkgs.writeText "dnsdist.conf" ''
    setLocal(${mkBind cfg})
    ${lib.optionalString cfg.dnscrypt.enable dnscryptSetup}
    ${cfg.extraConfig}
  '';

  dnscryptSetup = ''
    last_rotation = 0
    cert_serial = 0
    provider_key = ${toLua cfg.dnscrypt.providerKey}
    cert_lifetime = ${toLua cfg.dnscrypt.certLifetime} * 60

    function file_exists(name)
       local f = io.open(name, "r")
       return f ~= nil and io.close(f)
    end

    function dnscrypt_setup()
      -- generate provider keys on first run
      if provider_key == nil then
        provider_key = "/var/lib/dnsdist/private.key"
        if not file_exists(provider_key) then
          generateDNSCryptProviderKeys("/var/lib/dnsdist/public.key",
                                       "/var/lib/dnsdist/private.key")
          print("DNSCrypt: generated provider keypair")
        end
      end

      -- generate resolver certificate
      local now = os.time()
      generateDNSCryptCertificate(
        provider_key, "/run/dnsdist/resolver.cert", "/run/dnsdist/resolver.key",
        cert_serial, now - 60, now + cert_lifetime)
      addDNSCryptBind(
        ${mkBind cfg.dnscrypt}, ${toLua cfg.dnscrypt.providerName},
        "/run/dnsdist/resolver.cert", "/run/dnsdist/resolver.key")
    end

    function maintenance()
      -- certificate rotation
      local now = os.time()
      local dnscrypt = getDNSCryptBind(0)

      if ((now - last_rotation) > 0.9 * cert_lifetime) then
        -- generate and start using a new certificate
        dnscrypt:generateAndLoadInMemoryCertificate(
          provider_key, cert_serial + 1,
          now - 60, now + cert_lifetime)

        -- stop advertising the last certificate
        dnscrypt:markInactive(cert_serial)

        -- remove the second to last certificate
        if (cert_serial > 1)  then
          dnscrypt:removeInactiveCertificate(cert_serial - 1)
        end

        print("DNSCrypt: rotated certificate")

        -- increment serial number
        cert_serial = cert_serial + 1
        last_rotation = now
      end
    end

    dnscrypt_setup()
  '';

in
{
  options = {
    services.dnsdist = {
      enable = lib.mkEnableOption "dnsdist domain name server";

      dnscrypt = {
        enable = lib.mkEnableOption "a DNSCrypt endpoint to dnsdist";

        certLifetime = lib.mkOption {
          default = 15;

          description = ''
            The lifetime (in minutes) of the resolver certificate.
            This will be automatically rotated before expiration.
          '';

          type = lib.types.ints.positive;
        };

        listenAddress = lib.mkOption {
          default = "0.0.0.0";
          description = "Listen IP address of the endpoint";
          type = lib.types.str;
        };

        listenPort = lib.mkOption {
          default = 443;
          description = "Listen port of the endpoint";
          type = lib.types.port;
        };

        providerKey = lib.mkOption {
          default = null;

          description = ''
            The filepath to the provider secret key.
            If not given a new provider key pair will be generated in
            /var/lib/dnsdist on the first run.

            ::: {.note}
            The file must be readable by the dnsdist user/group.
            :::
          '';

          type = lib.types.nullOr lib.types.path;
        };

        providerName = lib.mkOption {
          default = "2.dnscrypt-cert.${config.networking.hostName}";
          defaultText = lib.literalExpression "2.dnscrypt-cert.\${config.networking.hostName}";

          description = ''
            The name that will be given to this DNSCrypt resolver.

            ::: {.note}
            The provider name must start with `2.dnscrypt-cert.`.
            :::
          '';

          example = "2.dnscrypt-cert.myresolver";
          type = lib.types.str;
        };

      };

      extraConfig = lib.mkOption {
        default = "";

        description = ''
          Extra lines to be added verbatim to dnsdist.conf.
        '';

        type = lib.types.lines;
      };

      listenAddress = lib.mkOption {
        default = "0.0.0.0";
        description = "Listen IP address";
        type = lib.types.str;
      };

      listenPort = lib.mkOption {
        default = 53;
        description = "Listen port";
        type = lib.types.port;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.packages = [ pkgs.dnsdist ];

    systemd.services.dnsdist = {
      serviceConfig = {
        ExecStart = [
          ""
          "${pkgs.dnsdist}/bin/dnsdist --supervised --disable-syslog --config ${configFile}"
        ];

        # upstream overrides for better nixos compatibility
        ExecStartPre = [
          ""
          "${pkgs.dnsdist}/bin/dnsdist --check-config --config ${configFile}"
        ];

        Group = "dnsdist";
        RuntimeDirectory = "dnsdist";
        StateDirectory = "dnsdist";
        User = "dnsdist";
      };

      startLimitIntervalSec = 0;
      wantedBy = [ "multi-user.target" ];
    };

    users.groups.dnsdist = { };

    users.users.dnsdist = {
      description = "dnsdist daemons user";
      group = "dnsdist";
      isSystemUser = true;
    };
  };
}
