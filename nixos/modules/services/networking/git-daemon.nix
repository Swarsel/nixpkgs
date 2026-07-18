{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.gitDaemon;

in
{

  ###### interface

  options = {
    services.gitDaemon = {

      options = lib.mkOption {
        default = "";
        description = "Extra configuration options to be passed to Git daemon.";
        type = lib.types.str;
      };

      enable = lib.mkOption {
        default = false;

        description = ''
          Enable Git daemon, which allows public hosting of git repositories
          without any access controls. This is mostly intended for read-only access.

          You can allow write access by setting daemon.receivepack configuration
          item of the repository to true. This is solely meant for a closed LAN setting
          where everybody is friendly.

          If you need any access controls, use something else.
        '';

        type = lib.types.bool;
      };

      package = lib.mkPackageOption pkgs "git" { };

      basePath = lib.mkOption {
        default = "";

        description = ''
          Remap all the path requests as relative to the given path. For example,
          if you set base-path to /srv/git, then if you later try to pull
          git://example.com/hello.git, Git daemon will interpret the path as /srv/git/hello.git.
        '';

        example = "/srv/git/";
        type = lib.types.str;
      };

      exportAll = lib.mkOption {
        default = false;

        description = ''
          Publish all directories that look like Git repositories (have the objects
          and refs subdirectories), even if they do not have the git-daemon-export-ok file.

          If disabled, you need to touch .git/git-daemon-export-ok in each repository
          you want the daemon to publish.

          Warning: enabling this without a repository whitelist or basePath
          publishes every git repository you have.
        '';

        type = lib.types.bool;
      };

      group = lib.mkOption {
        default = "git";
        description = "Group under which Git daemon would be running.";
        type = lib.types.str;
      };

      listenAddress = lib.mkOption {
        default = "";
        description = "Listen on a specific IP address or hostname.";
        example = "example.com";
        type = lib.types.str;
      };

      port = lib.mkOption {
        default = 9418;
        description = "Port to listen on.";
        type = lib.types.port;
      };

      repositories = lib.mkOption {
        default = [ ];

        description = ''
          A whitelist of paths of git repositories, or directories containing repositories
          all of which would be published. Paths must not end in "/".

          Warning: leaving this empty and enabling exportAll publishes all
          repositories in your filesystem or basePath if specified.
        '';

        example = [
          "/srv/git"
          "/home/user/git/repo2"
        ];

        type = lib.types.listOf lib.types.str;
      };

      user = lib.mkOption {
        default = "git";
        description = "User under which Git daemon would be running.";
        type = lib.types.str;
      };

    };
  };

  ###### implementation

  config = lib.mkIf cfg.enable {

    systemd.services.git-daemon = {
      after = [ "network.target" ];

      script =
        "${lib.getExe cfg.package} daemon --reuseaddr "
        + (lib.optionalString (cfg.basePath != "") "--base-path=${cfg.basePath} ")
        + (lib.optionalString (cfg.listenAddress != "") "--listen=${cfg.listenAddress} ")
        + "--port=${toString cfg.port} --user=${cfg.user} --group=${cfg.group} ${cfg.options} "
        + "--verbose "
        + (lib.optionalString cfg.exportAll "--export-all ")
        + lib.concatStringsSep " " cfg.repositories;

      wantedBy = [ "multi-user.target" ];
    };

    users.groups = lib.optionalAttrs (cfg.group == "git") {
      git.gid = config.ids.gids.git;
    };

    users.users = lib.optionalAttrs (cfg.user == "git") {
      git = {
        description = "Git daemon user";
        group = "git";
        uid = config.ids.uids.git;
      };
    };

  };

}
