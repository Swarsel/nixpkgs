{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf mkOption types;
  cfg = config.services.jenkinsSlave;
  masterCfg = config.services.jenkins;
in
{
  options = {
    services.jenkinsSlave = {
      # todo:
      # * assure the profile of the jenkins user has a JRE and any specified packages. This would
      # enable ssh slaves.
      # * Optionally configure the node as a jenkins ad-hoc slave. This would imply configuration
      # properties for the master node.
      enable = mkOption {
        default = false;

        description = ''
          If true the system will be configured to work as a jenkins slave.
          If the system is also configured to work as a jenkins master then this has no effect.
          In progress: Currently only assures the jenkins user is configured.
        '';

        type = types.bool;
      };

      group = mkOption {
        default = "jenkins";

        description = ''
          If the default slave agent user "jenkins" is configured then this is
          the primary group of that user.
        '';

        type = types.str;
      };

      home = mkOption {
        default = "/var/lib/jenkins";

        description = ''
          The path to use as JENKINS_HOME. If the default user "jenkins" is configured then
          this is the home of the "jenkins" user.
        '';

        type = types.path;
      };

      javaPackage = lib.mkPackageOption pkgs "jdk" { };

      user = mkOption {
        default = "jenkins";

        description = ''
          User the jenkins slave agent should execute under.
        '';

        type = types.str;
      };
    };
  };

  config = mkIf (cfg.enable && !masterCfg.enable) {
    programs.java = {
      enable = true;
      package = cfg.javaPackage;
    };

    users.groups = lib.optionalAttrs (cfg.group == "jenkins") {
      jenkins.gid = config.ids.gids.jenkins;
    };

    users.users = lib.optionalAttrs (cfg.user == "jenkins") {
      jenkins = {
        createHome = true;
        description = "jenkins user";
        group = cfg.group;
        home = cfg.home;
        uid = config.ids.uids.jenkins;
        useDefaultShell = true;
      };
    };
  };
}
