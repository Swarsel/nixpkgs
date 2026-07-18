{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.stash-clipboard;
  inherit (lib)
    mkPackageOption
    mkEnableOption
    mkOption
    types
    mkIf
    getExe
    concatStringsSep
    ;
in
{
  options.services.stash-clipboard = {
    enable = mkEnableOption "stash, a Wayland clipboard manager";
    package = mkPackageOption pkgs [ "stash-clipboard" ] { };

    arguments = mkOption {
      default = [ ];
      description = "A list of arguments to pass to stash watch.";
      example = [ "--max-items 10" ];
      type = types.listOf types.str;
    };

    excludedApps = mkOption {
      default = [ ];

      description = ''
        List of application classes to exclude from the database.
        Entries from these apps are still copied to the clipboard, but it will never be put inside the database.
      '';

      example = [ "Bitwarden" ];
      type = types.listOf types.str;
    };

    filterFile = mkOption {
      default = "";

      description = ''
        Stash can be configured to avoid storing clipboard entries that match a sensitive pattern, using a regular expression.
        The file set here should contain your regex pattern (no quotes).

        Example regex to block common password patterns:
        - (password|secret|api[_-]?key|token)[=: ]+[^\s]+
      '';

      example = "/etc/stash/clipboard_filter";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    systemd = {
      user.services.stash-clipboard = {
        after = [ "graphical-session.target" ];
        description = "Stash clipboard manager daemon";

        environment = mkIf (cfg.excludedApps != [ ]) {
          STASH_EXCLUDED_APPS = concatStringsSep "," cfg.excludedApps;
        };

        serviceConfig = {
          ExecStart = "${getExe cfg.package} ${concatStringsSep " " cfg.arguments} watch";
          LoadCredential = mkIf (cfg.filterFile != "") "clipboard_filter:${cfg.filterFile}";
        };

        wantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
