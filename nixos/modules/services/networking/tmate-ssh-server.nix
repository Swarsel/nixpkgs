{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.tmate-ssh-server;

  defaultKeysDir = "/etc/tmate-ssh-server-keys";
  edKey = "${defaultKeysDir}/ssh_host_ed25519_key";
  rsaKey = "${defaultKeysDir}/ssh_host_rsa_key";

  keysDir = if cfg.keysDir == null then defaultKeysDir else cfg.keysDir;

  domain = config.networking.domain;
in
{
  options.services.tmate-ssh-server = {
    enable = mkEnableOption "tmate ssh server";
    package = mkPackageOption pkgs "tmate-ssh-server" { };

    advertisedPort = mkOption {
      description = "External port advertised to clients";
      type = types.port;
    };

    host = mkOption {
      default = if domain == null then config.networking.hostName else domain;
      defaultText = lib.literalExpression "config.networking.domain or config.networking.hostName";
      description = "External host name";
      type = types.str;
    };

    keysDir = mkOption {
      default = null;
      description = "Directory containing ssh keys, defaulting to auto-generation";
      type = with types; nullOr str;
    };

    openFirewall = mkOption {
      default = false;
      description = "Whether to automatically open the specified ports in the firewall.";
      type = types.bool;
    };

    port = mkOption {
      default = 2222;
      description = "Listen port for the ssh server";
      type = types.port;
    };
  };

  config = mkIf cfg.enable {

    environment.systemPackages =
      let
        tmate-config = pkgs.writeText "tmate.conf" ''
          set -g tmate-server-host "${cfg.host}"
          set -g tmate-server-port ${toString cfg.port}
          set -g tmate-server-ed25519-fingerprint "@ed25519_fingerprint@"
          set -g tmate-server-rsa-fingerprint "@rsa_fingerprint@"
        '';
      in
      [
        (pkgs.writeShellApplication {
          name = "tmate-client-config";

          runtimeInputs = with pkgs; [
            openssh
            coreutils
          ];

          text = ''
            RSA_SIG="$(ssh-keygen -l -E SHA256 -f "${keysDir}/ssh_host_rsa_key.pub" | cut -d ' ' -f 2)"
            ED25519_SIG="$(ssh-keygen -l -E SHA256 -f "${keysDir}/ssh_host_ed25519_key.pub" | cut -d ' ' -f 2)"
            sed "s|@ed25519_fingerprint@|$ED25519_SIG|g" ${tmate-config} | \
              sed "s|@rsa_fingerprint@|$RSA_SIG|g"
          '';
        })
      ];

    networking.firewall.allowedTCPPorts = optionals cfg.openFirewall [ cfg.port ];

    services.tmate-ssh-server = {
      advertisedPort = mkDefault cfg.port;
    };

    systemd.services.tmate-ssh-server = {
      after = [ "network.target" ];
      description = "tmate SSH Server";

      preStart = mkIf (cfg.keysDir == null) ''
        if [[ ! -d ${defaultKeysDir} ]]
        then
          mkdir -p ${defaultKeysDir}
        fi
        if [[ ! -f ${edKey} ]]
        then
          ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -f ${edKey} -N ""
        fi
        if [[ ! -f ${rsaKey} ]]
        then
          ${pkgs.openssh}/bin/ssh-keygen -t rsa -f ${rsaKey} -N ""
        fi
      '';

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/tmate-ssh-server -h ${cfg.host} -p ${toString cfg.port} -q ${toString cfg.advertisedPort} -k ${keysDir}";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta = {
    maintainers = with maintainers; [ jlesquembre ];
  };

}
