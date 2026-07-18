{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkOption
    mkPackageOption
    mkIf
    types
    optionalString
    ;

  cfg = config.programs.tmux;

  defaultKeyMode = "emacs";
  defaultResize = 5;
  defaultShortcut = "b";
  defaultTerminal = "screen";

  boolToStr = value: if value then "on" else "off";

  tmuxConf = ''
    set  -g default-terminal "${cfg.terminal}"
    set  -g base-index      ${toString cfg.baseIndex}
    setw -g pane-base-index ${toString cfg.baseIndex}
    set  -g history-limit   ${toString cfg.historyLimit}

    ${optionalString cfg.newSession ''
      # Use -A to make new-session idempotent: attach if session "0" exists,
      # otherwise create it. This prevents duplicate sessions when multiple
      # configs (e.g., system and user) both enable newSession.
      new-session -A -s 0
    ''}

    ${optionalString cfg.reverseSplit ''
      bind v split-window -h
      bind s split-window -v
    ''}

    set -g status-keys ${cfg.keyMode}
    set -g mode-keys   ${cfg.keyMode}

    ${optionalString (cfg.keyMode == "vi" && cfg.customPaneNavigationAndResize) ''
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      bind -r H resize-pane -L ${toString cfg.resizeAmount}
      bind -r J resize-pane -D ${toString cfg.resizeAmount}
      bind -r K resize-pane -U ${toString cfg.resizeAmount}
      bind -r L resize-pane -R ${toString cfg.resizeAmount}
    ''}

    ${optionalString (cfg.shortcut != defaultShortcut) ''
      # rebind main key: C-${cfg.shortcut}
      unbind C-${defaultShortcut}
      set -g prefix C-${cfg.shortcut}
      bind ${cfg.shortcut} send-prefix
      bind C-${cfg.shortcut} last-window
    ''}

    setw -g aggressive-resize ${boolToStr cfg.aggressiveResize}
    setw -g clock-mode-style  ${if cfg.clock24 then "24" else "12"}
    set  -s escape-time       ${toString cfg.escapeTime}

    ${cfg.extraConfigBeforePlugins}

    ${lib.optionalString (cfg.plugins != [ ]) ''
      # Run plugins
      ${lib.concatMapStringsSep "\n" (x: "run-shell ${x.rtp}") cfg.plugins}

    ''}

    ${cfg.extraConfig}
  '';

in
{
  imports = [
    (lib.mkRenamedOptionModule
      [ "programs" "tmux" "extraTmuxConf" ]
      [ "programs" "tmux" "extraConfig" ]
    )
  ];

  ###### interface
  options = {
    programs.tmux = {

      enable = mkOption {
        default = false;
        description = "Whenever to configure {command}`tmux` system-wide.";
        relatedPackages = [ "tmux" ];
        type = types.bool;
      };

      package = mkPackageOption pkgs "tmux" { };

      aggressiveResize = mkOption {
        default = false;

        description = ''
          Resize the window to the size of the smallest session for which it is the current window.
        '';

        type = types.bool;
      };

      baseIndex = mkOption {
        default = 0;
        description = "Base index for windows and panes.";
        example = 1;
        type = types.int;
      };

      clock24 = mkOption {
        default = false;
        description = "Use 24 hour clock.";
        type = types.bool;
      };

      customPaneNavigationAndResize = mkOption {
        default = false;
        description = "Override the hjkl and HJKL bindings for pane navigation and resizing in VI mode.";
        type = types.bool;
      };

      escapeTime = mkOption {
        default = 500;
        description = "Time in milliseconds for which tmux waits after an escape is input.";
        example = 0;
        type = types.int;
      };

      extraConfig = mkOption {
        default = "";

        description = ''
          Additional contents of /etc/tmux.conf, to be run after sourcing plugins.
        '';

        type = types.lines;
      };

      extraConfigBeforePlugins = mkOption {
        default = "";

        description = ''
          Additional contents of /etc/tmux.conf, to be run before sourcing plugins.
        '';

        type = types.lines;
      };

      historyLimit = mkOption {
        default = 2000;
        description = "Maximum number of lines held in window history.";
        example = 5000;
        type = types.int;
      };

      keyMode = mkOption {
        default = defaultKeyMode;
        description = "VI or Emacs style shortcuts.";
        example = "vi";

        type = types.enum [
          "emacs"
          "vi"
        ];
      };

      newSession = mkOption {
        default = false;
        description = "Automatically spawn a session if trying to attach and none are running.";
        type = types.bool;
      };

      plugins = mkOption {
        default = [ ];
        description = "List of plugins to install.";
        example = lib.literalExpression "[ pkgs.tmuxPlugins.nord ]";
        type = types.listOf types.package;
      };

      resizeAmount = mkOption {
        default = defaultResize;
        description = "Number of lines/columns when resizing.";
        example = 10;
        type = types.int;
      };

      reverseSplit = mkOption {
        default = false;
        description = "Reverse the window split shortcuts.";
        type = types.bool;
      };

      secureSocket = mkOption {
        default = true;

        description = ''
          Store tmux socket under /run, which is more secure than /tmp, but as a
          downside it doesn't survive user logout.
        '';

        type = types.bool;
      };

      shortcut = mkOption {
        default = defaultShortcut;
        description = "Ctrl following by this key is used as the main shortcut.";
        example = "a";
        type = types.str;
      };

      terminal = mkOption {
        default = defaultTerminal;

        description = ''
          Set the $TERM variable. Use tmux-direct if italics or 24bit true color
          support is needed.
        '';

        example = "screen-256color";
        type = types.str;
      };

      withUtempter = mkOption {
        default = true;

        description = ''
          Whether to enable libutempter for tmux.
          This is required so that tmux can write to /var/run/utmp (which can be queried with `who` to display currently connected user sessions).
          Note, this will add a guid wrapper for the group utmp!
        '';

        type = types.bool;
      };
    };
  };

  ###### implementation
  config = mkIf cfg.enable {
    environment = {
      etc."tmux.conf".text = tmuxConf;
      systemPackages = [ cfg.package ] ++ cfg.plugins;

      variables = {
        TMUX_TMPDIR = lib.optional cfg.secureSocket ''''${XDG_RUNTIME_DIR:-"/run/user/$(id -u)"}'';
      };
    };

    security.wrappers = mkIf cfg.withUtempter {
      utempter = {
        group = "utmp";
        owner = "root";
        setgid = true;
        setuid = false;
        source = "${pkgs.libutempter}/lib/utempter/utempter";
      };
    };
  };

  meta.maintainers = with lib.maintainers; [ hxtmdev ];
}
