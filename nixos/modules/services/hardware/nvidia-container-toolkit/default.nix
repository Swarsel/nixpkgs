{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    (lib.mkRenamedOptionModule
      [ "virtualisation" "containers" "cdi" "dynamic" "nvidia" "enable" ]
      [ "hardware" "nvidia-container-toolkit" "enable" ]
    )
  ];

  options =
    let
      mountType = {
        options = {
          containerPath = lib.mkOption {
            description = "Container path.";
            type = lib.types.str;
          };

          hostPath = lib.mkOption {
            description = "Host path.";
            type = lib.types.str;
          };

          mountOptions = lib.mkOption {
            default = [
              "ro"
              "nosuid"
              "nodev"
              "bind"
            ];

            description = "Mount options.";
            type = lib.types.listOf lib.types.str;
          };
        };
      };
    in
    {
      hardware.nvidia-container-toolkit = {
        enable = lib.mkOption {
          default = false;

          description = ''
            Enable dynamic CDI configuration for Nvidia devices by running
            nvidia-container-toolkit on boot.
          '';

          type = lib.types.bool;
        };

        package = lib.mkPackageOption pkgs "nvidia-container-toolkit" { };

        csv-files = lib.mkOption {
          default = [ ];

          description = ''
            The path to the list of CSV files to use when generating the CDI specification in CSV mode.
          '';

          type = lib.types.listOf lib.types.path;
        };

        device-name-strategy = lib.mkOption {
          default = "index";

          description = ''
            Specify the strategy for generating device names,
            passed to `nvidia-ctk cdi generate`. This will affect how
            you reference the device using `nvidia.com/gpu=` in
            the container runtime.
          '';

          type = lib.types.enum [
            "index"
            "uuid"
            "type-index"
          ];
        };

        disable-hooks = lib.mkOption {
          default = [ "create-symlinks" ];

          description = ''
            List of hooks to disable when generating the CDI specification.
            Each hook name will be passed as `--disable-hook <hook-name>` to nvidia-ctk.
            Set to an empty list to disable no hooks.
          '';

          type = lib.types.listOf lib.types.nonEmptyStr;
        };

        discovery-mode = lib.mkOption {
          default = "auto";

          description = ''
            The mode to use when discovering the available entities.
          '';

          type = lib.types.enum [
            "auto"
            "csv"
            "nvml"
            "wsl"
          ];
        };

        enable-hooks = lib.mkOption {
          default = [ ];

          description = ''
            List of hooks to enable when generating the CDI specification.
            Each hook name will be passed as `--enable-hook <hook-name>` to nvidia-ctk.
            Set to an empty list to enable no hooks.
          '';

          type = lib.types.listOf lib.types.nonEmptyStr;
        };

        extraArgs = lib.mkOption {
          default = [ ];

          description = ''
            Extra arguments to be passed to nvidia-ctk.
          '';

          type = lib.types.listOf lib.types.str;
        };

        mount-nvidia-docker-1-directories = lib.mkOption {
          default = true;

          description = ''
            Mount nvidia-docker-1 directories on containers: /usr/local/nvidia/lib and
            /usr/local/nvidia/lib64.
          '';

          type = lib.types.bool;
        };

        mount-nvidia-executables = lib.mkOption {
          default = true;

          description = ''
            Mount executables nvidia-smi, nvidia-cuda-mps-control, nvidia-cuda-mps-server,
            nvidia-debugdump, nvidia-powerd and nvidia-ctk on containers.
          '';

          type = lib.types.bool;
        };

        mounts = lib.mkOption {
          default = [ ];
          description = "Mounts to be added to every container under the Nvidia CDI profile.";
          type = lib.types.listOf (lib.types.submodule mountType);
        };

        suppressNvidiaDriverAssertion = lib.mkOption {
          default = false;

          description = ''
            Suppress the assertion for installing Nvidia driver.
            Useful in WSL where drivers are mounted from Windows, not provided by NixOS.
          '';

          type = lib.types.bool;
        };
      };
    };

  config = lib.mkMerge [
    (lib.mkIf (config.virtualisation.docker.enableNvidia || config.virtualisation.podman.enableNvidia) {
      hardware.nvidia-container-toolkit.enable = lib.mkDefault true;

      warnings = lib.mkIf (!config.hardware.nvidia-container-toolkit.enable) [
        ''
          `virtualisation.docker.enableNvidia` or `virtualisation.podman.enableNvidia` is enabled,
          but `hardware.nvidia-container-toolkit.enable` is disabled. The nvidia-container-toolkit
          module is required for GPU support in containers.
        ''
      ];
    })
    (lib.mkIf config.virtualisation.docker.enableNvidia {
      environment.etc."nvidia-container-runtime/config.toml".text = ''
        disable-require = true
        supported-driver-capabilities = "compat32,compute,display,graphics,ngx,utility,video"
        [nvidia-container-cli]
        environment = []
        ldconfig = "@${lib.getExe' pkgs.glibc "ldconfig"}"
        load-kmods = true
        no-cgroups = false
        path = "${lib.getExe' pkgs.libnvidia-container "nvidia-container-cli"}"
        [nvidia-container-runtime]
        mode = "cdi"
        runtimes = ["docker-runc", "runc", "crun"]
        [nvidia-container-runtime-hook]
        path = "${lib.getOutput "tools" config.hardware.nvidia-container-toolkit.package}/bin/nvidia-container-runtime-hook"
        skip-mode-detection = false
        [nvidia-ctk]
        path = "${lib.getExe' config.hardware.nvidia-container-toolkit.package "nvidia-ctk"}"
      '';

      virtualisation.docker = {
        daemon.settings = {
          default-runtime = "nvidia";

          runtimes.nvidia = {
            args = [ ];
            path = "${lib.getOutput "tools" config.hardware.nvidia-container-toolkit.package}/bin/nvidia-container-runtime";
          };
        };

        extraPackages = [
          (lib.getOutput "tools" config.hardware.nvidia-container-toolkit.package)
        ];
      };
    })
    (lib.mkIf config.hardware.nvidia-container-toolkit.enable {
      assertions = [
        {
          assertion =
            config.hardware.nvidia.datacenter.enable
            || lib.elem "nvidia" config.services.xserver.videoDrivers
            || config.hardware.nvidia-container-toolkit.suppressNvidiaDriverAssertion;

          message = ''`nvidia-container-toolkit` requires nvidia drivers: set `hardware.nvidia.datacenter.enable`, add "nvidia" to `services.xserver.videoDrivers`, or set `hardware.nvidia-container-toolkit.suppressNvidiaDriverAssertion` if the driver is provided by another NixOS module (e.g. from NixOS-WSL)'';
        }
        {
          assertion =
            ((builtins.length config.hardware.nvidia-container-toolkit.csv-files) > 0)
            -> config.hardware.nvidia-container-toolkit.discovery-mode == "csv";

          message = "When CSV files are provided, `config.hardware.nvidia-container-toolkit.discovery-mode` has to be set to `csv`.";
        }
      ];

      hardware = {
        graphics.enable = lib.mkIf (!config.hardware.nvidia.datacenter.enable) true;

        nvidia-container-toolkit.mounts =
          let
            nvidia-driver = config.hardware.nvidia.package;
          in
          (lib.mkMerge [
            [
              {
                containerPath = pkgs.addDriverRunpath.driverLink;
                hostPath = pkgs.addDriverRunpath.driverLink;
              }
              {
                containerPath = "${lib.getLib nvidia-driver}";
                hostPath = "${lib.getLib nvidia-driver}";
              }
              {
                containerPath = "${lib.getLib pkgs.glibc}/lib";
                hostPath = "${lib.getLib pkgs.glibc}/lib";
              }
              {
                containerPath = "${lib.getLib pkgs.glibc}/lib64";
                hostPath = "${lib.getLib pkgs.glibc}/lib64";
              }
            ]
            (lib.mkIf config.hardware.nvidia-container-toolkit.mount-nvidia-executables [
              {
                containerPath = "/usr/bin/nvidia-cuda-mps-control";
                hostPath = lib.getExe' nvidia-driver "nvidia-cuda-mps-control";
              }
              {
                containerPath = "/usr/bin/nvidia-cuda-mps-server";
                hostPath = lib.getExe' nvidia-driver "nvidia-cuda-mps-server";
              }
              {
                containerPath = "/usr/bin/nvidia-debugdump";
                hostPath = lib.getExe' nvidia-driver "nvidia-debugdump";
              }
              {
                containerPath = "/usr/bin/nvidia-powerd";
                hostPath = lib.getExe' nvidia-driver "nvidia-powerd";
              }
              {
                containerPath = "/usr/bin/nvidia-smi";
                hostPath = lib.getExe' nvidia-driver "nvidia-smi";
              }
            ])
            # nvidia-docker 1.0 uses /usr/local/nvidia/lib{,64}
            #   e.g.
            #     - https://gitlab.com/nvidia/container-images/cuda/-/blob/e3ff10eab3a1424fe394899df0e0f8ca5a410f0f/dist/12.3.1/ubi9/base/Dockerfile#L44
            #     - https://github.com/NVIDIA/nvidia-docker/blob/01d2c9436620d7dde4672e414698afe6da4a282f/src/nvidia/volumes.go#L104-L173
            (lib.mkIf config.hardware.nvidia-container-toolkit.mount-nvidia-docker-1-directories [
              {
                containerPath = "/usr/local/nvidia/lib";
                hostPath = "${lib.getLib nvidia-driver}/lib";
              }
              {
                containerPath = "/usr/local/nvidia/lib64";
                hostPath = "${lib.getLib nvidia-driver}/lib";
              }
            ])
          ]);
      };

      services.udev.extraRules = ''
        KERNEL=="nvidia", RUN+="${lib.getExe' config.systemd.package "systemctl"} --no-block restart nvidia-container-toolkit-cdi-generator.service'"
      '';

      systemd.services.nvidia-container-toolkit-cdi-generator = {
        description = "Container Device Interface (CDI) for Nvidia generator";

        requiredBy = lib.mkMerge [
          (lib.mkIf config.virtualisation.docker.enable [ "docker.service" ])
          (lib.mkIf config.virtualisation.podman.enable [ "podman.service" ])
        ];

        serviceConfig = {
          ExecStart =
            let
              script = pkgs.callPackage ./cdi-generate.nix {
                inherit (config.hardware.nvidia-container-toolkit)
                  csv-files
                  device-name-strategy
                  discovery-mode
                  mounts
                  disable-hooks
                  enable-hooks
                  extraArgs
                  ;

                nvidia-container-toolkit = config.hardware.nvidia-container-toolkit.package;
                nvidia-driver = config.hardware.nvidia.package;
              };
            in
            lib.getExe script;

          # We wait for the udev events queue to empty in the *hope* that the
          # devices needed here become available. This is terribly broken and
          # essentially no better than a random sleep(). See PR #452645 for
          # an attempt to fix this issue.
          ExecStartPre = "-${lib.getExe' pkgs.systemd "udevadm"} settle --timeout=180";
          RemainAfterExit = true;
          RuntimeDirectory = "cdi";
          Type = "oneshot";
        };

        wantedBy = [ "multi-user.target" ];
      };

      virtualisation = {
        containers.containersConf.settings = {
          engine = {
            cdi_spec_dirs = [
              "/etc/cdi"
              "/var/run/cdi"
            ];
          };
        };

        docker =
          let
            dockerVersion = config.virtualisation.docker.package.version;
          in
          {
            daemon.settings = lib.mkIf (lib.versionAtLeast dockerVersion "25") {
              features.cdi = true;
            };

            rootless = {
              daemon.settings = lib.mkIf (lib.versionAtLeast dockerVersion "25") {
                features.cdi = true;
              };

              extraPackages = [
                (lib.getOutput "tools" config.hardware.nvidia-container-toolkit.package)
              ];
            };
          };
      };

      warnings = lib.mkMerge [
        (lib.mkIf config.virtualisation.podman.enableNvidia [
          "Setting virtualisation.podman.enableNvidia has no effect and will be removed soon."
        ])
      ];
    })
  ];

}
