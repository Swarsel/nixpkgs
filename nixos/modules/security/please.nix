{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.security.please;
  ini = pkgs.formats.ini { };
in
{
  options.security.please = {
    enable = lib.mkEnableOption ''
      please, a Sudo clone which allows a users to execute a command or edit a
      file as another user
    '';

    package = lib.mkPackageOption pkgs "please" { };

    settings = lib.mkOption {
      default = { };

      description = ''
        Please configuration. Refer to
        <https://github.com/edneville/please/blob/master/please.ini.md> for
        details.
      '';

      example = {
        jim_edit_etc_hosts_as_root = {
          editmode = 644;
          name = "jim";
          require_pass = true;
          rule = "/etc/hosts";
          target = "root";
          type = "edit";
        };

        jim_run_any_as_root = {
          name = "jim";
          require_pass = false;
          rule = ".*";
          target = "root";
          type = "run";
        };
      };

      type = ini.type;
    };

    wheelNeedsPassword = lib.mkOption {
      default = true;

      description = ''
        Whether users of the `wheel` group must provide a password to run
        commands or edit files with {command}`please` and
        {command}`pleaseedit` respectively.
      '';

      type = lib.types.bool;
    };
  };

  config = lib.mkIf cfg.enable {
    environment = {
      etc."please.ini".source = ini.generate "please.ini" (
        cfg.settings
        // rec {
          root_edit_as_any = root_run_as_any // {
            type = "edit";
          };

          root_list_as_any = root_run_as_any // {
            type = "list";
          };

          # The "root" user is allowed to do anything by default and this cannot
          # be overridden.
          root_run_as_any = {
            name = "root";
            require_pass = false;
            rule = ".*";
            target = ".*";
            type = "run";
          };
        }
      );

      systemPackages = [ cfg.package ];
    };

    security.pam.services.please = {
      sshAgentAuth = true;
      usshAuth = true;
    };

    security.please.settings = rec {
      wheel_edit_as_any = wheel_run_as_any // {
        type = "edit";
      };

      wheel_list_as_any = wheel_run_as_any // {
        type = "list";
      };

      # The "wheel" group is allowed to do anything by default but this can be
      # overridden.
      wheel_run_as_any = {
        group = true;
        name = "wheel";
        require_pass = cfg.wheelNeedsPassword;
        rule = ".*";
        target = ".*";
        type = "run";
      };
    };

    security.wrappers =
      let
        owner = "root";
        group = "root";
        setuid = true;
      in
      {
        please = {
          inherit owner group setuid;
          source = "${cfg.package}/bin/please";
        };

        pleaseedit = {
          inherit owner group setuid;
          source = "${cfg.package}/bin/pleaseedit";
        };
      };
  };
}
