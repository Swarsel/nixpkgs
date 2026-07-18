{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.gollum;
in

{
  imports = [
    (lib.mkRemovedOptionModule
      [
        "services"
        "gollum"
        "mathjax"
      ]
      "MathJax rendering might be discontinued in the future, use services.gollum.math instead to enable KaTeX rendering or file a PR if you really need Mathjax"
    )
    (lib.mkRemovedOptionModule [
      "services"
      "gollum"
      "local-time"
    ] "Set the value in services.gollum.extraConfig")
  ];

  options.services.gollum = {
    enable = lib.mkEnableOption "Gollum, a git-powered wiki service";
    package = lib.mkPackageOption pkgs "gollum" { };

    address = lib.mkOption {
      default = "0.0.0.0";
      description = "IP address on which the web server will listen.";
      type = lib.types.str;
    };

    allowUploads = lib.mkOption {
      default = null;
      description = "Enable uploads of external files";

      type = lib.types.nullOr (
        lib.types.enum [
          "dir"
          "page"
        ]
      );
    };

    branch = lib.mkOption {
      default = "master";
      description = "Git branch to serve";
      example = "develop";
      type = lib.types.str;
    };

    emoji = lib.mkOption {
      default = false;
      description = "Parse and interpret emoji tags";
      type = lib.types.bool;
    };

    extraConfig = lib.mkOption {
      default = "";
      description = "Content of the configuration file";

      example = ''
        wiki_options = {
          show_local_time: true
        }

        Precious::App.set(:wiki_options, wiki_options)
      '';

      type = lib.types.lines;
    };

    group = lib.mkOption {
      default = "gollum";
      description = "Specifies the owner group of the wiki directory";
      type = lib.types.str;
    };

    h1-title = lib.mkOption {
      default = false;
      description = "Use the first h1 as page title";
      type = lib.types.bool;
    };

    math = lib.mkOption {
      default = false;
      description = "Enable support for math rendering using KaTeX";
      type = lib.types.bool;
    };

    no-edit = lib.mkOption {
      default = false;
      description = "Disable editing pages";
      type = lib.types.bool;
    };

    port = lib.mkOption {
      default = 4567;
      description = "Port on which the web server will run.";
      type = lib.types.port;
    };

    stateDir = lib.mkOption {
      default = "/var/lib/gollum";
      description = "Specifies the path of the repository directory. If it does not exist, Gollum will create it on startup.";
      type = lib.types.path;
    };

    user = lib.mkOption {
      default = "gollum";
      description = "Specifies the owner of the wiki directory";
      type = lib.types.str;
    };

    user-icons = lib.mkOption {
      default = null;
      description = "Enable specific user icons for history view";

      type = lib.types.nullOr (
        lib.types.enum [
          "gravatar"
          "identicon"
        ]
      );
    };
  };

  config = lib.mkIf cfg.enable {

    systemd.services.gollum = {
      after = [ "network.target" ];
      description = "Gollum wiki";
      path = [ pkgs.git ];

      preStart = ''
        # Check if it's a bare repository.
        IS_BARE=$(git -C "${cfg.stateDir}" rev-parse --is-bare-repository 2>/dev/null || echo "false")

        if [ "$IS_BARE" = "true" ]; then
          echo "Directory is a bare repository. Skipping initialization."
        else
          echo "Directory is not a bare repository. Initializing..."
          git init "${cfg.stateDir}"
        fi
      '';

      serviceConfig = {
        ExecStart = ''
          ${cfg.package}/bin/gollum \
            --port ${toString cfg.port} \
            --host ${cfg.address} \
            --config ${pkgs.writeText "gollum-config.rb" cfg.extraConfig} \
            --ref ${cfg.branch} \
            ${lib.optionalString cfg.math "--math"} \
            ${lib.optionalString cfg.emoji "--emoji"} \
            ${lib.optionalString cfg.h1-title "--h1-title"} \
            ${lib.optionalString cfg.no-edit "--no-edit"} \
            ${lib.optionalString (cfg.allowUploads != null) "--allow-uploads ${cfg.allowUploads}"} \
            ${lib.optionalString (cfg.user-icons != null) "--user-icons ${cfg.user-icons}"} \
            ${cfg.stateDir}
        '';

        Group = cfg.group;
        User = cfg.user;
        WorkingDirectory = cfg.stateDir;
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.rules = [ "d '${cfg.stateDir}' - ${cfg.user} ${cfg.group} - -" ];
    users.groups."${cfg.group}" = { };

    users.users.gollum = lib.mkIf (cfg.user == "gollum") {
      createHome = false;
      description = "Gollum user";
      group = cfg.group;
      isSystemUser = true;
    };
  };

  meta.maintainers = with lib.maintainers; [
    erictapen
    bbenno
  ];
}
