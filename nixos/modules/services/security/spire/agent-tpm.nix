{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.spire.agent;
in
{
  options.services.spire.agent.settings.plugins.NodeAttestor.tpm = lib.mkOption {
    default = null;
    description = "TPM 2.0 node attestation plugin. When set, automatically enables security.tpm2 and grants the spire-agent user access to the TPM device.";

    type = lib.types.nullOr (
      lib.types.submodule {
        options.plugin_cmd = lib.mkOption {
          default = lib.getExe' pkgs.spire-tpm-plugin "tpm_attestor_agent";
          defaultText = lib.literalExpression ''lib.getExe' pkgs.spire-tpm-plugin "tpm_attestor_agent"'';
          description = "Path to the TPM attestor agent plugin binary.";
          type = lib.types.str;
        };

        freeformType = (pkgs.formats.hcl1 { }).type;
      }
    );
  };

  config = lib.mkIf (cfg.enable && cfg.settings.plugins.NodeAttestor.tpm != null) {
    security.tpm2.enable = true;

    systemd.services.spire-agent.serviceConfig.SupplementaryGroups = [
      config.security.tpm2.tssGroup
    ];
  };
}
