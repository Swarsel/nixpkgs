{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;
  format = pkgs.formats.toml { };
  cfg = config.services.hebbot;
  settingsFile = format.generate "config.toml" cfg.settings;
  mkTemplateOption =
    templateName:
    mkOption {
      description = ''
        A path to the Markdown file for the ${templateName}.
      '';

      type = types.path;
    };
in
{
  options.services.hebbot = {
    enable = mkEnableOption "hebbot";
    package = lib.mkPackageOption pkgs "hebbot" { };

    botPasswordFile = mkOption {
      description = ''
        A path to the password file for your bot.

        Consider using a path that does not end up in your Nix store
        as it would be world readable.
      '';

      type = types.path;
    };

    settings = mkOption {
      default = { };

      description = ''
        Configuration for Hebbot, see, for examples:

        - <https://github.com/matrix-org/twim-config/blob/master/config.toml>
        - <https://gitlab.gnome.org/Teams/Websites/thisweek.gnome.org/-/blob/main/hebbot/config.toml>
      '';

      type = format.type;
    };

    templates = {
      project = mkTemplateOption "project template";
      report = mkTemplateOption "report template";
      section = mkTemplateOption "section template";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.hebbot = {
      after = [ "network.target" ];
      description = "hebbot - a TWIM-style Matrix bot written in Rust";

      preStart = ''
        ln -sf ${cfg.templates.project} ./project_template.md
        ln -sf ${cfg.templates.report} ./report_template.md
        ln -sf ${cfg.templates.section} ./section_template.md
        ln -sf ${settingsFile} ./config.toml
      '';

      script = ''
        export BOT_PASSWORD="$(cat $CREDENTIALS_DIRECTORY/bot-password-file)"
        ${lib.getExe cfg.package}
      '';

      serviceConfig = {
        DynamicUser = true;
        LoadCredential = "bot-password-file:${cfg.botPasswordFile}";
        Restart = "on-failure";
        RestartSec = "10s";
        StateDirectory = "hebbot";
        WorkingDirectory = "/var/lib/hebbot";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = [ ];
}
