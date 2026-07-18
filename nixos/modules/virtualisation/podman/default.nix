{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  cfg = config.virtualisation.podman;
  json = pkgs.formats.json { };

  inherit (lib) mkOption types;
  inherit (pkgs) stdenv;

  # Provides a fake "docker" binary mapping to podman
  dockerCompat =
    pkgs.runCommand "${cfg.package.pname}-docker-compat-${cfg.package.version}"
      {
        inherit (cfg.package) meta;
        nativeBuildInputs = [ pkgs.installShellFiles ];

        outputs = [
          "out"
          "man"
        ];

        preferLocalBuild = true;
      }
      (
        ''
          mkdir -p $out/bin
          ln -s ${cfg.package}/bin/podman $out/bin/docker

          mkdir -p $man/share/man/man1
          for f in ${cfg.package.man}/share/man/man1/*; do
            basename=$(basename $f | sed s/podman/docker/g)
            ln -s $f $man/share/man/man1/$basename
          done
        ''
        + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
          export HOME=$(mktemp -d) # work around `docker <cmd>`
          installShellCompletion --cmd docker \
            --bash <($out/bin/docker completion bash) \
            --zsh <($out/bin/docker completion zsh) \
            --fish <($out/bin/docker completion fish)
        ''
      );

in
{
  imports = [
    (lib.mkRemovedOptionModule [
      "virtualisation"
      "podman"
      "defaultNetwork"
      "dnsname"
    ] "Use virtualisation.podman.defaultNetwork.settings.dns_enabled instead.")
    (lib.mkRemovedOptionModule [
      "virtualisation"
      "podman"
      "defaultNetwork"
      "extraPlugins"
    ] "Netavark isn't compatible with CNI plugins.")
    ./network-socket.nix
  ];

  options.virtualisation.podman = {

    enable = mkOption {
      default = false;

      description = ''
        This option enables Podman, a daemonless container engine for
        developing, managing, and running OCI Containers on your Linux System.

        It is a drop-in replacement for the {command}`docker` command.
      '';

      type = types.bool;
    };

    package =
      (lib.mkPackageOption pkgs "podman" {
        extraDescription = ''
          This package will automatically include extra packages and runtimes.
        '';
      })
      // {
        apply =
          pkg:
          pkg.override {
            extraPackages =
              cfg.extraPackages
              ++ [
                "/run/wrappers" # setuid shadow
                config.systemd.package # To allow systemd-based container healthchecks
              ]
              ++ lib.optional (config.boot.supportedFilesystems.zfs or false) config.boot.zfs.package;

            extraRuntimes =
              cfg.extraRuntimes
              ++
                lib.optionals
                  (
                    config.virtualisation.containers.containersConf.settings.network.default_rootless_network_cmd or ""
                    == "slirp4netns"
                  )
                  (
                    with pkgs;
                    [
                      slirp4netns
                    ]
                  );
          };
      };

    autoPrune = {
      enable = mkOption {
        default = false;

        description = ''
          Whether to periodically prune Podman resources. If enabled, a
          systemd timer will run `podman system prune -f`
          as specified by the `dates` option.
        '';

        type = types.bool;
      };

      dates = mkOption {
        default = "weekly";

        description = ''
          Specification (in the format described by
          {manpage}`systemd.time(7)`) of the time at
          which the prune will occur.
        '';

        type = types.str;
      };

      flags = mkOption {
        default = [ ];

        description = ''
          Any additional flags passed to {command}`podman system prune`.
        '';

        example = [ "--all" ];
        type = types.listOf types.str;
      };
    };

    defaultNetwork.settings = lib.mkOption {
      default = { };

      description = ''
        Settings for podman's default network.
      '';

      example = lib.literalExpression "{ dns_enabled = true; }";
      type = json.type;
    };

    dockerCompat = mkOption {
      default = false;

      description = ''
        Create an alias mapping {command}`docker` to {command}`podman`.
      '';

      type = types.bool;
    };

    dockerSocket.enable = mkOption {
      default = false;

      description = ''
        Make the Podman socket available in place of the Docker socket, so
        Docker tools can find the Podman socket.

        Podman implements the Docker API.

        Users must be in the `podman` group in order to connect. As
        with Docker, members of this group can gain root access.
      '';

      type = types.bool;
    };

    enableNvidia = mkOption {
      default = false;

      description = ''
        **Deprecated**, please use {option}`hardware.nvidia-container-toolkit.enable` instead.

        Enable use of Nvidia GPUs from within podman containers.
      '';

      type = types.bool;
    };

    extraPackages = mkOption {
      default = [ ];

      description = ''
        Extra dependencies for podman to be placed on $PATH in the wrapper.
      '';

      type = with types; listOf package;
    };

    extraRuntimes = mkOption {
      # keep the default in sync with the podman package
      default = lib.optionals pkgs.stdenv.hostPlatform.isLinux [ pkgs.runc ];
      defaultText = lib.literalExpression "lib.optionals pkgs.stdenv.hostPlatform.isLinux [ pkgs.runc ]";

      description = ''
        Extra runtime packages to be installed in the Podman wrapper.
        Those are then placed in libexec/podman, i.e. are seen as podman internal commands.
      '';

      example = lib.literalExpression ''
        [
          pkgs.gvisor
        ]
      '';

      type = with types; listOf package;
    };

  };

  config =
    let
      networkConfig = (
        {
          dns_enabled = false;
          driver = "bridge";
          id = "0000000000000000000000000000000000000000000000000000000000000000";
          internal = false;

          ipam_options = {
            driver = "host-local";
          };

          ipv6_enabled = false;
          name = "podman";
          network_interface = "podman0";

          subnets = [
            {
              gateway = "10.88.0.1";
              subnet = "10.88.0.0/16";
            }
          ];
        }
        // cfg.defaultNetwork.settings
      );
      inherit (networkConfig) dns_enabled network_interface;
    in
    lib.mkIf cfg.enable {
      assertions = [
        {
          assertion = cfg.dockerCompat -> !config.virtualisation.docker.enable;
          message = "Option dockerCompat conflicts with docker";
        }
        {
          assertion = cfg.dockerSocket.enable -> !config.virtualisation.docker.enable;

          message = ''
            The options virtualisation.podman.dockerSocket.enable and virtualisation.docker.enable conflict, because only one can serve the socket.
          '';
        }
      ];

      # https://github.com/containers/podman/blob/097cc6eb6dd8e598c0e8676d21267b4edb11e144/docs/tutorials/basic_networking.md#default-network
      environment.etc."containers/networks/podman.json" = lib.mkIf (cfg.defaultNetwork.settings != { }) {
        source = json.generate "podman.json" networkConfig;
      };

      environment.systemPackages = [ cfg.package ] ++ lib.optional cfg.dockerCompat dockerCompat;

      # containers cannot reach aardvark-dns otherwise
      networking.firewall = lib.mkIf (config.networking.firewall.backend != "firewalld") {
        interfaces.${network_interface}.allowedUDPPorts = lib.mkIf dns_enabled [ 53 ];
      };

      systemd.packages = [ cfg.package ];
      systemd.services.podman.environment = config.networking.proxy.envVars;

      systemd.services.podman-prune = {
        after = [ "podman.service" ];
        description = "Prune podman resources";
        requires = [ "podman.service" ];
        restartIfChanged = false;

        serviceConfig = {
          ExecStart = utils.escapeSystemdExecArgs (
            [
              (lib.getExe cfg.package)
              "system"
              "prune"
              "-f"
            ]
            ++ cfg.autoPrune.flags
          );

          Type = "oneshot";
        };

        startAt = lib.optional cfg.autoPrune.enable cfg.autoPrune.dates;
        unitConfig.X-StopOnRemoval = false;
      };

      systemd.sockets.podman.socketConfig.SocketGroup = "podman";

      # Podman does not support multiple sockets, as of podman 5.0.2, so we use
      # a symlink. Unfortunately this does not let us use an alternate group,
      # such as `docker`.
      systemd.sockets.podman.socketConfig.Symlinks = lib.mkIf cfg.dockerSocket.enable [
        "/run/docker.sock"
      ];

      systemd.sockets.podman.wantedBy = [ "sockets.target" ];

      systemd.timers.podman-prune.timerConfig = lib.mkIf cfg.autoPrune.enable {
        Persistent = true;
        RandomizedDelaySec = 1800;
      };

      systemd.tmpfiles.packages = [
        # The /run/podman rule interferes with our podman group, so we remove
        # it and let the systemd socket logic take care of it.
        (pkgs.runCommand "podman-tmpfiles-nixos"
          {
            package = cfg.package;
            preferLocalBuild = true;
          }
          ''
            mkdir -p $out/lib/tmpfiles.d/
            grep -v 'D! /run/podman 0700 root root' \
              <$package/lib/tmpfiles.d/podman.conf \
              >$out/lib/tmpfiles.d/podman.conf
          ''
        )
      ];

      systemd.user.services.podman.environment = config.networking.proxy.envVars;
      systemd.user.sockets.podman.wantedBy = [ "sockets.target" ];
      users.groups.podman = { };

      virtualisation.containers = {
        enable = true; # Enable common /etc/containers configuration

        containersConf.settings = {
          network = {
            firewall_driver = lib.mkIf config.networking.nftables.enable "nftables";
            network_backend = "netavark";
          };
        };
      };

      warnings = lib.optionals cfg.enableNvidia [
        ''
          You have set virtualisation.podman.enableNvidia. This option is deprecated, please set hardware.nvidia-container-toolkit.enable instead.
        ''
      ];
    };

  meta = {
    teams = [ lib.teams.podman ];
  };
}
