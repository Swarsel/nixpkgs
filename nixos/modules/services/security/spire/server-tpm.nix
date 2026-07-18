{
  lib,
  pkgs,
  ...
}:
let
  format = pkgs.formats.hcl1 { };
in
{
  options.services.spire.server.settings.plugins.NodeAttestor.tpm = lib.mkOption {
    default = null;

    description = ''
      TPM 2.0 node attestation plugin from
      [spire-tpm-plugin](https://github.com/spiffe/spire-tpm-plugin).
    '';

    type = lib.types.nullOr (
      lib.types.submodule {
        options = {
          plugin_cmd = lib.mkOption {
            default = lib.getExe' pkgs.spire-tpm-plugin "tpm_attestor_server";
            defaultText = lib.literalExpression ''lib.getExe' pkgs.spire-tpm-plugin "tpm_attestor_server"'';
            description = "Path to the TPM attestor server plugin binary.";
            type = lib.types.str;
          };

          plugin_data = lib.mkOption {
            default = { };

            description = ''
              Plugin data for the TPM NodeAttestor. Either `ca_path`,
              `hash_path`, or both must be configured.
            '';

            type = lib.types.submodule {
              options = {
                ca_path = lib.mkOption {
                  default = null;

                  description = ''
                    The path to the CA directory. Contains the manufacturer CA
                    cert that signed the TPM's EK certificate in PEM or DER
                    format.
                  '';

                  type = lib.types.nullOr lib.types.str;
                };

                hash_path = lib.mkOption {
                  default = null;

                  description = ''
                    The path to the Hash directory. Contains empty files named
                    after the EK public key hash.
                  '';

                  type = lib.types.nullOr lib.types.str;
                };
              };

              freeformType = format.type;
            };
          };
        };

        freeformType = format.type;
      }
    );
  };
}
