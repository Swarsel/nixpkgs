{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.security.sudo-rs;

  toUserString = user: if (lib.isInt user) then "#${toString user}" else "${user}";
  toGroupString = group: if (lib.isInt group) then "%#${toString group}" else "%${group}";

  toCommandOptionsString =
    options: "${lib.concatStringsSep ":" options}${lib.optionalString (lib.length options != 0) ":"} ";

  toCommandsString =
    commands:
    lib.concatStringsSep ", " (
      map (
        command:
        if (lib.isString command) then
          command
        else
          "${toCommandOptionsString command.options}${command.command}"
      ) commands
    );

in

{

  ###### interface

  options.security.sudo-rs = {

    enable = lib.mkEnableOption ''
      a memory-safe implementation of the {command}`sudo` command,
      which allows non-root users to execute commands as root
    '';

    package = lib.mkPackageOption pkgs "sudo-rs" { };

    configFile = lib.mkOption {
      # Note: if syntax errors are detected in this file, the NixOS
      # configuration will fail to build.
      description = ''
        This string contains the contents of the
        {file}`sudoers` file.
      '';

      type = lib.types.lines;
    };

    defaultOptions = lib.mkOption {
      default = [ "SETENV" ];

      description = ''
        Options used for the default rules, granting `root` and the
        `wheel` group permission to run any command as any user.
      '';

      type = with lib.types; listOf str;
    };

    execWheelOnly = lib.mkOption {
      default = false;

      description = ''
        Only allow members of the `wheel` group to execute sudo by
        setting the executable's permissions accordingly.
        This prevents users that are not members of `wheel` from
        exploiting vulnerabilities in sudo such as CVE-2021-3156.
      '';

      type = lib.types.bool;
    };

    extraConfig = lib.mkOption {
      default = "";

      description = ''
        Extra configuration text appended to {file}`sudoers`.
      '';

      type = lib.types.lines;
    };

    extraRules = lib.mkOption {
      default = [ ];

      description = ''
        Define specific rules to be in the {file}`sudoers` file.
        More specific rules should come after more general ones in order to
        yield the expected behavior. You can use `lib.mkBefore`/`lib.mkAfter` to ensure
        this is the case when configuration options are merged.
      '';

      example = lib.literalExpression ''
        [
          # Allow execution of any command by all users in group sudo,
          # requiring a password.
          { groups = [ "sudo" ]; commands = [ "ALL" ]; }

          # Allow execution of "/home/root/secret.sh" by user `backup`, `database`
          # and the group with GID `1006` without a password.
          { users = [ "backup" "database" ]; groups = [ 1006 ];
            commands = [ { command = "/home/root/secret.sh"; options = [ "SETENV" "NOPASSWD" ]; } ]; }

          # Allow all users of group `bar` to run two executables as user `foo`
          # with arguments being pre-set.
          { groups = [ "bar" ]; runAs = "foo";
            commands =
              [ "/home/baz/cmd1.sh hello-sudo"
                  { command = '''/home/baz/cmd2.sh ""'''; options = [ "SETENV" ]; } ]; }
        ]
      '';

      type =
        with lib.types;
        listOf (submodule {
          options = {
            commands = lib.mkOption {
              description = ''
                The commands for which the rule should apply.
              '';

              type =
                with lib.types;
                listOf (
                  either str (submodule {

                    options = {
                      options = lib.mkOption {
                        default = [ ];

                        description = ''
                          Options for running the command. Refer to the [sudo manual](https://www.sudo.ws/man/1.7.10/sudoers.man.html).
                        '';

                        type =
                          with lib.types;
                          listOf (enum [
                            "NOPASSWD"
                            "PASSWD"
                            "NOEXEC"
                            "EXEC"
                            "SETENV"
                            "NOSETENV"
                            "LOG_INPUT"
                            "NOLOG_INPUT"
                            "LOG_OUTPUT"
                            "NOLOG_OUTPUT"
                          ]);
                      };

                      command = lib.mkOption {
                        description = ''
                          A command being either just a path to a binary to allow any arguments,
                          the full command with arguments pre-set or with `""` used as the argument,
                          not allowing arguments to the command at all.
                        '';

                        type = with lib.types; str;
                      };
                    };

                  })
                );
            };

            groups = lib.mkOption {
              default = [ ];

              description = ''
                The groups / GIDs this rule should apply for.
              '';

              type = with lib.types; listOf (either str int);
            };

            host = lib.mkOption {
              default = "ALL";

              description = ''
                For what host this rule should apply.
              '';

              type = lib.types.str;
            };

            runAs = lib.mkOption {
              default = "ALL:ALL";

              description = ''
                Under which user/group the specified command is allowed to run.

                A user can be specified using just the username: `"foo"`.
                It is also possible to specify a user/group combination using `"foo:bar"`
                or to only allow running as a specific group with `":bar"`.
              '';

              type = with lib.types; str;
            };

            users = lib.mkOption {
              default = [ ];

              description = ''
                The usernames / UIDs this rule should apply for.
              '';

              type = with lib.types; listOf (either str int);
            };
          };
        });
    };

    wheelNeedsPassword = lib.mkOption {
      default = true;

      description = ''
        Whether users of the `wheel` group must
        provide a password to run commands as super user via {command}`sudo`.
      '';

      type = lib.types.bool;
    };
  };

  ###### implementation

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !config.security.sudo.enable;
        message = "`security.sudo` and `security.sudo-rs` cannot both be enabled";
      }
    ];

    environment.etc.sudoers = {
      mode = "0440";

      source = pkgs.runCommand "sudoers" {
        preferLocalBuild = true;
        src = pkgs.writeText "sudoers-in" cfg.configFile;
      } "${pkgs.buildPackages.sudo-rs}/bin/visudo -f $src -c && cp $src $out";
    };

    environment.systemPackages = [ cfg.package ];

    security.pam.services = {
      su-l = {
        forwardXAuth = true;
        logFailures = true;
        rootOK = true;
      };

      sudo = {
        sshAgentAuth = true;
        usshAuth = true;
      };

      sudo-i = {
        sshAgentAuth = true;
        usshAuth = true;
      };
    };

    security.shadow.su.package = lib.mkDefault cfg.package;
    security.sudo.enable = lib.mkDefault false;

    security.sudo-rs.configFile = lib.concatStringsSep "\n" (
      lib.filter (s: s != "") [
        ''
          # Don't edit this file. Set the NixOS options ‘security.sudo-rs.configFile’
          # or ‘security.sudo-rs.extraRules’ instead.
        ''
        (lib.pipe cfg.extraRules [
          (lib.filter (rule: lib.length rule.commands != 0))
          (map (rule: [
            (map (
              user: "${toUserString user}     ${rule.host}=(${rule.runAs})    ${toCommandsString rule.commands}"
            ) rule.users)
            (map (
              group: "${toGroupString group}  ${rule.host}=(${rule.runAs})    ${toCommandsString rule.commands}"
            ) rule.groups)
          ]))
          lib.flatten
          (lib.concatStringsSep "\n")
        ])
        "\n"
        (lib.optionalString (cfg.extraConfig != "") ''
          # extraConfig
          ${cfg.extraConfig}
        '')
      ]
    );

    security.sudo-rs.extraRules =
      let
        defaultRule =
          {
            groups ? [ ],
            opts ? [ ],
            users ? [ ],
          }:
          [
            {
              inherit users groups;

              commands = [
                {
                  options = opts ++ cfg.defaultOptions;
                  command = "ALL";
                }
              ];
            }
          ];
      in
      lib.mkMerge [
        # This is ordered before users' `lib.mkBefore` rules,
        # so as not to introduce unexpected changes.
        (lib.mkOrder 400 (defaultRule {
          users = [ "root" ];
        }))

        # This is ordered to show before (most) other rules, but
        # late-enough for a user to `lib.mkBefore` it.
        (lib.mkOrder 600 (defaultRule {
          groups = [ "wheel" ];
          opts = (lib.optional (!cfg.wheelNeedsPassword) "NOPASSWD");
        }))
      ];

    security.wrappers =
      let
        owner = "root";
        group = if cfg.execWheelOnly then "wheel" else "root";
        setuid = true;
        permissions = if cfg.execWheelOnly then "u+rx,g+x" else "u+rx,g+x,o+x";
      in
      {
        sudo = {
          inherit
            owner
            group
            setuid
            permissions
            ;

          source = lib.getExe cfg.package;
        };

        sudoedit = {
          inherit
            owner
            group
            setuid
            permissions
            ;

          source = lib.getExe' cfg.package "sudoedit";
        };
      };

  };

  meta.maintainers = [ lib.maintainers.nicoo ];

}
