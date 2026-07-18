{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.keter;
  yaml = pkgs.formats.yaml { };
in
{
  imports = [
    (lib.mkRenamedOptionModule [ "services" "keter" "keterRoot" ] [ "services" "keter" "root" ])
    (lib.mkRenamedOptionModule [ "services" "keter" "keterPackage" ] [ "services" "keter" "package" ])
  ];

  options.services.keter = {
    enable = lib.mkEnableOption ''
      keter, a web app deployment manager.
      Note that this module only support loading of webapps:
      Keep an old app running and swap the ports when the new one is booted
    '';

    package = lib.mkPackageOption pkgs [ "haskellPackages" "keter" ] { };

    bundle = {
      appName = lib.mkOption {
        default = "myapp";
        description = "The name keter assigns to this bundle";
        type = lib.types.str;
      };

      domain = lib.mkOption {
        default = "example.com";
        description = "The domain keter will bind to";
        type = lib.types.str;
      };

      executable = lib.mkOption {
        description = "The executable to be run";
        type = lib.types.path;
      };

      publicScript = lib.mkOption {
        default = "";

        description = ''
          Allows loading of public environment variables,
          these are emitted to the log so it shouldn't contain secrets.
        '';

        example = "ADMIN_EMAIL=hi@example.com";
        type = lib.types.str;
      };

      secretScript = lib.mkOption {
        default = "";
        description = "Allows loading of private environment variables";
        example = "MY_AWS_KEY=$(cat /run/keys/AWS_ACCESS_KEY_ID)";
        type = lib.types.str;
      };
    };

    globalKeterConfig = lib.mkOption {
      description = "Global config for keter, see <https://github.com/snoyberg/keter/blob/master/etc/keter-config.yaml> for reference";

      type = lib.types.submodule {
        options = {
          ip-from-header = lib.mkOption {
            default = true;
            description = "You want that ip-from-header in the nginx setup case. It allows nginx setting the original ip address rather then it being localhost (due to reverse proxying)";
            type = lib.types.bool;
          };

          listeners = lib.mkOption {
            default = [
              {
                host = "*";
                port = 6981;
              }
            ];

            description = ''
              You want that ip-from-header in
              the nginx setup case.
              It allows nginx setting the original ip address rather
              then it being localhost (due to reverse proxying).
              However if you configure keter to accept connections
              directly you may want to set this to false.'';

            type = lib.types.listOf (
              lib.types.submodule {
                options = {
                  host = lib.mkOption {
                    description = "host";
                    type = lib.types.str;
                  };

                  port = lib.mkOption {
                    description = "port";
                    type = lib.types.port;
                  };
                };
              }
            );
          };

          rotate-logs = lib.mkOption {
            default = false;

            description = ''
              emits keter logs and it's applications to stderr.
              which allows journald to capture them.
              Set to true to let keter put the logs in files
              (useful on non systemd systems, this is the old approach
              where keter handled log management)'';

            type = lib.types.bool;
          };
        };

        freeformType = yaml.type;
      };
    };

    root = lib.mkOption {
      default = "/var/lib/keter";
      description = "Mutable state folder for keter";
      type = lib.types.str;
    };

  };

  config = lib.mkIf cfg.enable (
    let
      incoming = "${cfg.root}/incoming";

      globalKeterConfigFile = pkgs.writeTextFile {
        name = "keter-config.yml";
        text = (lib.generators.toYAML { } (cfg.globalKeterConfig // { root = cfg.root; }));
      };

      # If things are expected to change often, put it in the bundle!
      bundle = pkgs.callPackage ./bundle.nix (
        cfg.bundle
        // {
          keterDomain = cfg.bundle.domain;
          keterExecutable = executable;
        }
      );

      # This indirection is required to ensure the nix path
      # gets copied over to the target machine in remote deployments.
      # Furthermore, it's important that we use exec to
      # run the binary otherwise we get process leakage due to this
      # being executed on every change.
      executable = pkgs.writeShellScript "bundle-wrapper" ''
        set -e
        ${cfg.bundle.secretScript}
        set -xe
        ${cfg.bundle.publicScript}
        exec ${cfg.bundle.executable}
      '';

    in
    {
      systemd.services.keter = {
        after = [
          "network.target"
          "local-fs.target"
          "postgresql.target"
        ];

        description = "keter app loader";

        script = ''
          set -xe
          mkdir -p ${incoming}
          ${lib.getExe cfg.package} ${globalKeterConfigFile};
        '';

        serviceConfig = {
          Restart = "always";
          RestartSec = "10s";
        };

        wantedBy = [
          "multi-user.target"
          "nginx.service"
        ];
      };

      # On deploy this will load our app, by moving it into the incoming dir
      # If the bundle content changes, this will run again.
      # Because the bundle content contains the nix path to the executable,
      # we inherit nix based cache busting.
      systemd.services.load-keter-bundle = {
        after = [ "keter.service" ];
        description = "load keter bundle into incoming folder";

        path = [
          executable
          cfg.bundle.executable
        ]; # this is a hack to get the executable copied over to the machine.

        # we can't override keter bundles because it'll stop the previous app
        # https://github.com/snoyberg/keter#deploying
        script = ''
          set -xe
          cp ${bundle}/bundle.tar.gz.keter ${incoming}/${cfg.bundle.appName}.keter
        '';

        wantedBy = [ "multi-user.target" ];
      };
    }
  );

  meta = {
    maintainers = with lib.maintainers; [ jappie ];
  };
}
