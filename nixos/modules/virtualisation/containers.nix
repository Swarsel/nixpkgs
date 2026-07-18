{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.virtualisation.containers;

  inherit (lib) literalExpression mkOption types;

  toml = pkgs.formats.toml { };
in
{
  options.virtualisation.containers = {

    enable = mkOption {
      default = false;

      description = ''
        This option enables the common /etc/containers configuration module.
      '';

      type = types.bool;
    };

    containersConf.cniPlugins = mkOption {
      defaultText = literalExpression ''
        [
          pkgs.cni-plugins
        ]
      '';

      description = ''
        CNI plugins to install on the system.
      '';

      example = literalExpression ''
        [
          pkgs.cniPlugins.dnsname
        ]
      '';

      type = types.listOf types.package;
    };

    containersConf.settings = mkOption {
      default = { };
      description = "containers.conf configuration";
      type = toml.type;
    };

    ociSeccompBpfHook.enable = mkOption {
      default = false;
      description = "Enable the OCI seccomp BPF hook";
      type = types.bool;
    };

    policy = mkOption {
      default = { };

      description = ''
        Signature verification policy file.
        If this option is empty the default policy file from
        `skopeo` will be used.
      '';

      example = literalExpression ''
        {
          default = [ { type = "insecureAcceptAnything"; } ];
          transports = {
            docker-daemon = {
              "" = [ { type = "insecureAcceptAnything"; } ];
            };
          };
        }
      '';

      type = types.attrs;
    };

    registries = {
      block = mkOption {
        default = [ ];

        description = ''
          List of blocked repositories.
        '';

        type = types.listOf types.str;
      };

      insecure = mkOption {
        default = [ ];

        description = ''
          List of insecure repositories.
        '';

        type = types.listOf types.str;
      };

      search = mkOption {
        default = [
          "docker.io"
          "quay.io"
        ];

        description = ''
          List of repositories to search.
        '';

        type = types.listOf types.str;
      };
    };

    storage.settings = mkOption {
      description = "storage.conf configuration";
      type = toml.type;
    };

  };

  config = lib.mkIf cfg.enable {

    environment.etc = {
      "containers/containers.conf".source = toml.generate "containers.conf" cfg.containersConf.settings;

      "containers/policy.json".source =
        if cfg.policy != { } then
          pkgs.writeText "policy.json" (builtins.toJSON cfg.policy)
        else
          "${pkgs.skopeo.policy}/default-policy.json";

      "containers/registries.conf".source = toml.generate "registries.conf" {
        registries = lib.mapAttrs (n: v: { registries = v; }) cfg.registries;
      };

      "containers/storage.conf".source = toml.generate "storage.conf" cfg.storage.settings;
    };

    virtualisation.containers.containersConf.cniPlugins = [ pkgs.cni-plugins ];

    virtualisation.containers.containersConf.settings = {
      engine = {
        init_path = "${pkgs.catatonit}/bin/catatonit";
      }
      // lib.optionalAttrs cfg.ociSeccompBpfHook.enable {
        hooks_dir = [ config.boot.kernelPackages.oci-seccomp-bpf-hook ];
      };

      network.cni_plugin_dirs = map (p: "${lib.getBin p}/bin") cfg.containersConf.cniPlugins;
    };

    virtualisation.containers.storage.settings.storage = {
      driver = lib.mkDefault "overlay";
      graphroot = lib.mkDefault "/var/lib/containers/storage";
      runroot = lib.mkDefault "/run/containers/storage";
    };

  };

  meta = {
    teams = [ lib.teams.podman ];
  };

}
