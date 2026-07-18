# This module defines a standard configuration for NixOS global environment.

# Most of the stuff here should probably be moved elsewhere sometime.

{ config, lib, ... }:

let

  cfg = config.environment;

in

{

  config = {

    environment.extraInit = ''
      export NIX_USER_PROFILE_DIR="/nix/var/nix/profiles/per-user/$USER"
      export NIX_PROFILES="${builtins.concatStringsSep " " (lib.reverseList cfg.profiles)}"
    '';

    environment.pathsToLink = [
      "/lib/gtk-2.0"
      "/lib/gtk-3.0"
      "/lib/gtk-4.0"
    ];

    # TODO: move most of these elsewhere
    environment.profileRelativeSessionVariables = {
      GTK_PATH = [
        "/lib/gtk-2.0"
        "/lib/gtk-3.0"
        "/lib/gtk-4.0"
      ];

      INFOPATH = [
        "/info"
        "/share/info"
      ];

      LIBEXEC_PATH = [ "/libexec" ];
      PATH = [ "/bin" ];
      QTWEBKIT_PLUGIN_PATH = [ "/lib/mozilla/plugins/" ];
      XDG_CONFIG_DIRS = [ "/etc/xdg" ];
      XDG_DATA_DIRS = [ "/share" ];
    };

    environment.profiles = lib.mkAfter [
      "/nix/var/nix/profiles/default"
      "/run/current-system/sw"
    ];

    environment.sessionVariables = {
      XDG_CONFIG_DIRS = [ "/etc/xdg" ]; # needs to be before profile-relative paths to allow changes through environment.etc
    };

    environment.variables = {
      EDITOR = lib.mkDefault "nano";
      NIXPKGS_CONFIG = "/etc/nix/nixpkgs-config.nix";
      # note: many programs exec() this directly, so default options for less must not
      # be specified here; do so in the default value of programs.less.envVariables instead
      PAGER = lib.mkDefault "less";
    };

    # since we set PAGER to this above, make sure it's installed
    programs.less.enable = true;

  };

}
