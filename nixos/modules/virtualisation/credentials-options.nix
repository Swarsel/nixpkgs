{ lib, pkgs, ... }:
{
  options.virtualisation.credentials = lib.mkOption {
    default = { };

    description = ''
      Credentials to pass to the VM or container using systemd's credential system.

      See {manpage}`systemd.exec(5)`, {manpage}`systemd-creds(1)` and https://systemd.io/CREDENTIALS/ for more
      information about systemd credentials.
    '';

    example = lib.literalExpression ''
      {
        database-password = {
          text = "my-secret-password";
        };
        ssl-cert = {
          source = "./cert.pem";
        };
        binary-key = {
          source = "./private.der";
        };
      }
    '';

    type = lib.types.attrsOf (
      lib.types.submodule (
        {
          config,
          options,
          name,
          ...
        }:
        {
          options = {
            source = lib.mkOption {
              default = null;

              description = ''
                Source file on the host containing the credential data.
              '';

              type = lib.types.nullOr (lib.types.pathWith { });
            };

            text = lib.mkOption {
              default = null;

              description = ''
                Text content of the credential.

                For binary data or when the credential content should come from
                an existing file, use `source` instead.

                ::: {.warning}
                The text here is stored in the host's nix store as a file.
                :::
              '';

              type = lib.types.nullOr lib.types.str;
            };
          };

          config.source = lib.mkIf (config.text != null) (
            lib.mkDerivedConfig options.text (pkgs.writeText name)
          );
        }
      )
    );
  };
}
