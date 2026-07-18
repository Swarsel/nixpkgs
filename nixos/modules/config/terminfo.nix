# This module manages the terminfo database
# and its integration in the system.
{
  config,
  lib,
  pkgs,
  ...
}:
{

  options = {
    environment.enableAllTerminfo = lib.mkOption {
      default = false;

      description = ''
        Whether to install all terminfo outputs
      '';

      type = lib.types.bool;
    };

    security.sudo.keepTerminfo = lib.mkOption {
      default = true;

      description = ''
        Whether to preserve the `TERMINFO` and `TERMINFO_DIRS`
        environment variables, for `root` and the `wheel` group.
      '';

      type = lib.types.bool;
    };
  };

  config = {

    boot.initrd.systemd.contents = lib.listToAttrs (
      lib.map
        (ti: lib.nameValuePair "/etc/terminfo/${ti}" { source = "${pkgs.ncurses}/share/terminfo/${ti}"; })
        [
          "l/linux"
          "v/vt100"
          "v/vt102"
          "v/vt220"
        ]
    );

    environment.etc.terminfo = {
      source = "${config.system.path}/share/terminfo";
    };

    environment.extraInit = ''

      # reset TERM with new TERMINFO available (if any)
      export TERM=$TERM
    '';

    environment.pathsToLink = [
      "/share/terminfo"
    ];

    environment.profileRelativeSessionVariables = {
      TERMINFO_DIRS = [ "/share/terminfo" ];
    };

    # This should not contain packages that are broken or can't build, since it
    # will break this expression
    #
    # can be generated with:
    # lib.attrNames (lib.filterAttrs
    #  (_: drv: (builtins.tryEval (lib.isDerivation drv && drv ? terminfo)).value)
    #  pkgs)
    environment.systemPackages = lib.mkIf config.environment.enableAllTerminfo (
      map (x: x.terminfo) (
        with pkgs.pkgsBuildBuild;
        [
          alacritty
          contour
          foot
          ghostty
          kitty
          mtm
          rio
          rxvt-unicode-unwrapped
          rxvt-unicode-unwrapped-emoji
          st
          tmux
          wezterm
          yaft
        ]
      )
    );

    security =
      let
        extraConfig = ''

          # Keep terminfo database for root and %wheel.
          Defaults:root,%wheel env_keep+=TERMINFO_DIRS
          Defaults:root,%wheel env_keep+=TERMINFO
        '';
      in
      lib.mkIf config.security.sudo.keepTerminfo {
        sudo = { inherit extraConfig; };
        sudo-rs = { inherit extraConfig; };
      };
  };
}
