{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.dkimproxy-out;
  keydir = "/var/lib/dkimproxy-out";
  privkey = "${keydir}/private.key";
  pubkey = "${keydir}/public.key";
in
{
  ##### interface
  options = {
    services.dkimproxy-out = {
      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to enable dkimproxy_out.

          Note that a key will be auto-generated, and can be found in
          ${keydir}.
        '';

        type = lib.types.bool;
      };

      domains = lib.mkOption {
        description = "List of domains DKIMproxy can sign for.";

        example = [
          "example.org"
          "example.com"
        ];

        type = with lib.types; listOf str;
      };

      keySize = lib.mkOption {
        default = 2048;

        description = ''
          Size of the RSA key to use to sign outgoing emails. Note that the
          maximum mandatorily verified as per RFC6376 is 2048.
        '';

        type = lib.types.int;
      };

      listen = lib.mkOption {
        description = "Address:port DKIMproxy should listen on.";
        example = "127.0.0.1:10027";
        type = lib.types.str;
      };

      relay = lib.mkOption {
        description = "Address:port DKIMproxy should forward mail to.";
        example = "127.0.0.1:10028";
        type = lib.types.str;
      };

      selector = lib.mkOption {
        description = ''
          The selector to use for DKIM key identification.

          For example, if 'selector1' is used here, then for each domain
          'example.org' given in `domain`, 'selector1._domainkey.example.org'
          should contain the TXT record indicating the public key is the one
          in ${pubkey}: "v=DKIM1; t=s; p=[THE PUBLIC KEY]".
        '';

        example = "selector1";
        type = lib.types.str;
      };
      # TODO: allow signature for other schemes than dkim(c=relaxed/relaxed)?
      # This being the scheme used by gmail, maybe nothing more is needed for
      # reasonable use.
    };
  };

  ##### implementation
  config =
    let
      configfile = pkgs.writeText "dkimproxy_out.conf" ''
        listen ${cfg.listen}
        relay ${cfg.relay}

        domain ${lib.concatStringsSep "," cfg.domains}
        selector ${cfg.selector}

        signature dkim(c=relaxed/relaxed)

        keyfile ${privkey}
      '';
    in
    lib.mkIf cfg.enable {
      systemd.services.dkimproxy-out = {
        description = "DKIMproxy_out";

        preStart = ''
          if [ ! -d "${keydir}" ]; then
            mkdir -p "${keydir}"
            chmod 0700 "${keydir}"
            ${pkgs.openssl}/bin/openssl genrsa -out "${privkey}" ${toString cfg.keySize}
            ${pkgs.openssl}/bin/openssl rsa -in "${privkey}" -pubout -out "${pubkey}"
            chown -R dkimproxy-out:dkimproxy-out "${keydir}"
          fi
        '';

        serviceConfig = {
          ExecStart = "${pkgs.dkimproxy}/bin/dkimproxy.out --conf_file=${configfile}";
          PermissionsStartOnly = true;
          User = "dkimproxy-out";
        };

        wantedBy = [ "multi-user.target" ];
      };

      users.groups.dkimproxy-out = { };

      users.users.dkimproxy-out = {
        description = "DKIMproxy_out daemon";
        group = "dkimproxy-out";
        isSystemUser = true;
      };
    };

}
