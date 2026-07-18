{
  config,
  lib,
  pkgs,
  options,
  ...
}:
let

  cfg = config.services.jupyter;

  package = pkgs.python3.withPackages (
    ps:
    [
      cfg.package
    ]
    ++ cfg.extraPackages
  );

  kernels = (
    pkgs.jupyter-kernel.create {
      definitions = if cfg.kernels != null then cfg.kernels else pkgs.jupyter-kernel.default;
    }
  );

  notebookConfig = pkgs.writeText "jupyter_server_config.py" ''
    ${cfg.notebookConfig}
    c.ServerApp.password = "${cfg.password}"
  '';

in
{
  options.services.jupyter = {
    enable = lib.mkEnableOption "Jupyter development server";

    package = lib.mkPackageOption pkgs [
      "python3"
      "pkgs"
      "jupyter"
    ] { };

    command = lib.mkOption {
      default = "jupyter notebook";

      description = ''
        Which command the service runs. Note that not all jupyter packages
        have all commands, e.g. `jupyter lab` isn't present in the `notebook` package.
      '';

      example = "jupyter lab";
      type = lib.types.str;
    };

    extraEnvironmentVariables = lib.mkOption {
      inherit (options.environment.variables) type apply;
      default = { };
      description = "Extra environment variables to be set in the runtime context of jupyter notebook";

      example = lib.literalExpression ''
        {
          PLAYWRIGHT_BROWSERS_PATH = "''${pkgs.playwright-driver.browsers}";
          PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = "true";
        }
      '';
    };

    extraPackages = lib.mkOption {
      default = [ ];
      description = "Extra packages to be available in the jupyter runtime environment";

      example = lib.literalExpression ''
        [
          pkgs.python3.pkgs.nbconvert
          pkgs.python3.pkgs.playwright
        ]
      '';

      type = lib.types.listOf lib.types.package;
    };

    group = lib.mkOption {
      default = "jupyter";

      description = ''
        Name of the group used to run the jupyter service.
        Use this if you want to create a group of users that are able to view the notebook directory's content.
      '';

      example = "users";
      type = lib.types.str;
    };

    ip = lib.mkOption {
      default = "localhost";

      description = ''
        IP address Jupyter will be listening on.
      '';

      type = lib.types.str;
    };

    kernels = lib.mkOption {
      default = null;

      description = ''
        Declarative kernel config.

        Kernels can be declared in any language that supports and has the required
        dependencies to communicate with a jupyter server.
        In python's case, it means that ipykernel package must always be included in
        the list of packages of the targeted environment.
      '';

      example = lib.literalExpression ''
        {
          python3 = let
            env = (pkgs.python3.withPackages (pythonPackages: with pythonPackages; [
                    ipykernel
                    pandas
                    scikit-learn
                  ]));
          in {
            displayName = "Python 3 for machine learning";
            argv = [
              "''${env.interpreter}"
              "-m"
              "ipykernel_launcher"
              "-f"
              "{connection_file}"
            ];
            language = "python";
            logo32 = "''${env.sitePackages}/ipykernel/resources/logo-32x32.png";
            logo64 = "''${env.sitePackages}/ipykernel/resources/logo-64x64.png";
            extraPaths = {
              "cool.txt" = pkgs.writeText "cool" "cool content";
            };
          };
        }
      '';

      type = lib.types.nullOr (
        lib.types.attrsOf (
          lib.types.submodule (
            import ./kernel-options.nix {
              inherit lib pkgs;
            }
          )
        )
      );
    };

    notebookConfig = lib.mkOption {
      default = "";

      description = ''
        Raw jupyter config.
        Please use the password configuration option to set a password instead of passing it in here.
      '';

      type = lib.types.lines;
    };

    notebookDir = lib.mkOption {
      default = "~/";

      description = ''
        Root directory for notebooks.
      '';

      type = lib.types.str;
    };

    password = lib.mkOption {
      description = ''
        Password to use with notebook.
        Can be generated following: <https://jupyter-server.readthedocs.io/en/stable/operators/public-server.html#preparing-a-hashed-password>
      '';

      example = "argon2:$argon2id$v=19$m=10240,t=10,p=8$48hF+vTUuy1LB83/GzNhUg$J1nx4jPWD7PwOJHs5OtDW8pjYK2s0c1R3rYGbSIKB54";
      type = lib.types.str;
    };

    port = lib.mkOption {
      default = 8888;

      description = ''
        Port number Jupyter will be listening on.
      '';

      type = lib.types.port;
    };

    user = lib.mkOption {
      default = "jupyter";

      description = ''
        Name of the user used to run the jupyter service.
        For security reason, jupyter should really not be run as root.
        If not set (jupyter), the service will create a jupyter user with appropriate settings.
      '';

      example = "aborsu";
      type = lib.types.str;
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      systemd.services.jupyter = {
        after = [ "network.target" ];
        description = "Jupyter development server";

        environment = {
          JUPYTER_PATH = toString kernels;
        }
        // cfg.extraEnvironmentVariables;

        # TODO: Patch notebook so we can explicitly pass in a shell
        path = [ pkgs.bash ]; # needed for sh in cell magic to work

        serviceConfig = {
          ExecStart = ''
            ${package}/bin/${cfg.command} \
                        --no-browser \
                        --ip=${cfg.ip} \
                        --port=${toString cfg.port} --port-retries 0 \
                        --notebook-dir=${cfg.notebookDir} \
                        --JupyterApp.config_file=${notebookConfig}

          '';

          Group = cfg.group;
          Restart = "always";
          User = cfg.user;
          WorkingDirectory = "~";
        };

        wantedBy = [ "multi-user.target" ];
      };
    })
    (lib.mkIf (cfg.enable && (cfg.group == "jupyter")) {
      users.groups.jupyter = { };
    })
    (lib.mkIf (cfg.enable && (cfg.user == "jupyter")) {
      users.extraUsers.jupyter = {
        inherit (cfg) group;
        createHome = true;
        home = "/var/lib/jupyter";
        isSystemUser = true;
        useDefaultShell = true; # needed so that the user can start a terminal.
      };
    })
  ];

  meta.maintainers = with lib.maintainers; [
    b-m-f
  ];
}
