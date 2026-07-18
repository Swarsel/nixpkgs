{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    maintainers
    mapAttrs'
    mkEnableOption
    mkOption
    nameValuePair
    optionalString
    types
    ;
  mkSystemdService =
    name: cfg:
    nameValuePair "gitwatch-${name}" (
      let
        getvar = flag: var: optionalString (cfg."${var}" != null) "${flag} ${cfg."${var}"}";
        branch = getvar "-b" "branch";
        remote = getvar "-r" "remote";
        message = getvar "-m" "message";
      in
      rec {
        inherit (cfg) enable;
        after = [ "network-online.target" ];
        description = "gitwatch for ${name}";

        path = with pkgs; [
          gitwatch
          git
          openssh
        ];

        script = ''
          if [ -n "${cfg.remote}" ] && ! [ -d "${cfg.path}" ]; then
            git clone ${branch} "${cfg.remote}" "${cfg.path}"
          fi
          gitwatch ${remote} ${message} ${branch} ${cfg.path}
        '';

        serviceConfig.User = cfg.user;
        wantedBy = [ "multi-user.target" ];
        wants = after;
      }
    );
in
{
  options.services.gitwatch = mkOption {
    default = { };

    description = ''
      A set of git repositories to watch for. See
      [gitwatch](https://github.com/gitwatch/gitwatch) for more.
    '';

    example = {
      disabled-repo = {
        enable = false;
        branch = "autobranch";
        path = "/home/user/disabled-project";
        remote = "git@github.com:me/my-old-project.git";
        user = "user";
      };

      my-repo = {
        enable = true;
        message = "Auto-commit by gitwatch on %d";
        path = "/home/user/watched-project";
        remote = "git@github.com:me/my-project.git";
        user = "user";
      };
    };

    type =
      with types;
      attrsOf (submodule {
        options = {
          enable = mkEnableOption "watching for repo";

          branch = mkOption {
            default = null;
            description = "Optional branch in remote repository";
            type = nullOr str;
          };

          message = lib.mkOption {
            default = null;
            description = "Optional text to use in as commit message; all occurrences of `%d` will be replaced by formatted date/time";
            type = nullOr str;
          };

          path = mkOption {
            description = "The path to repo in local machine";
            type = str;
          };

          remote = mkOption {
            default = null;
            description = "Optional url of remote repository";
            type = nullOr str;
          };

          user = mkOption {
            default = "root";
            description = "The name of services's user";
            type = str;
          };
        };
      });
  };

  config.systemd.services = mapAttrs' mkSystemdService config.services.gitwatch;

  meta.maintainers = with maintainers; [
    shved
    zareix
  ];
}
