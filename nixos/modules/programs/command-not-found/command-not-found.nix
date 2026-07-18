# This module provides suggestions of packages to install if the user
# tries to run a missing command in Bash.  This is implemented using a
# SQLite database that maps program names to Nix package names (e.g.,
# "pdflatex" is mapped to "tetex").

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.command-not-found;
  commandNotFound = pkgs.replaceVarsWith {
    dir = "bin";
    isExecutable = true;
    name = "command-not-found";

    replacements = {
      inherit (cfg) dbPath;

      perl = pkgs.perl.withPackages (p: [
        p.DBDSQLite
        p.StringShellQuote
      ]);
    };

    src = ./command-not-found.pl;
  };

in

{
  options.programs.command-not-found = {

    enable = lib.mkOption {
      default = builtins.pathExists config.programs.command-not-found.dbPath;

      defaultText = lib.literalExpression ''
        builtins.pathExists config.programs.command-not-found.dbPath
      '';

      description = ''
        Whether interactive shells should show which Nix package (if
        any) provides a missing command.

        See also nix-index and nix-index-database as an alternative for flakes-based systems.

        Additionally, having the env var NIX_AUTO_RUN set will automatically run the matching package, and with NIX_AUTO_RUN_INTERACTIVE it will confirm the package before running.
      '';

      type = lib.types.bool;
    };

    dbPath = lib.mkOption {
      default = pkgs.path + "/programs.sqlite";

      defaultText = lib.literalExpression ''
        pkgs.path + "/programs.sqlite"
      '';

      description = ''
        Absolute path to `programs.sqlite`, which contains mappings from binary names to package names.

        If a nixpkgs tarball from https://channels.nixos.org is used as the source of nixpkgs, this file will be provided and this option be set by default.

        To use the stateful `programs.sqlite` database, set this option to
        `/nix/var/nix/profiles/per-user/root/channels/nixos/programs.sqlite`.
        If you do so, you can update it with `sudo nix-channels --update`.
      '';

      type = lib.types.path;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ commandNotFound ];

    programs.bash.interactiveShellInit = ''
      command_not_found_handle() {
        '${commandNotFound}/bin/command-not-found' "$@"
      }
    '';

    # NOTE: Fish by itself checks for nixos command-not-found, let's instead makes it explicit.
    programs.fish.interactiveShellInit = ''
      function fish_command_not_found
         "${commandNotFound}/bin/command-not-found" $argv
      end
    '';

    programs.zsh.interactiveShellInit = ''
      command_not_found_handler() {
        '${commandNotFound}/bin/command-not-found' "$@"
      }
    '';
  };
}
