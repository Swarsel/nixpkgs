{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.git;
in

{
  options = {
    programs.git = {
      config = lib.mkOption {
        default = [ ];

        description = ''
          Configuration to write to /etc/gitconfig. A list can also be
          specified to keep the configuration in order. For example, setting
          `config` to `[ { foo.x = 42; } { bar.y = 42; }]` will put the `foo`
          section before the `bar` section unlike the default alphabetical
          order, which can be helpful for sections such as `include` and
          `includeIf`. See the CONFIGURATION FILE section of {manpage}`git-config(1)` for
          more information.
        '';

        example = {
          init.defaultBranch = "main";

          url."https://github.com/".insteadOf = [
            "gh:"
            "github:"
          ];
        };

        type =
          with lib.types;
          let
            gitini = attrsOf (attrsOf anything);
          in
          either gitini (listOf gitini)
          // {
            merge =
              loc: defs:
              let
                config =
                  builtins.foldl'
                    (
                      acc:
                      { value, ... }@x:
                      acc
                      // (
                        if builtins.isList value then
                          {
                            ordered = acc.ordered ++ value;
                          }
                        else
                          {
                            unordered = acc.unordered ++ [ x ];
                          }
                      )
                    )
                    {
                      ordered = [ ];
                      unordered = [ ];
                    }
                    defs;
              in
              [ (gitini.merge loc config.unordered) ] ++ config.ordered;
          };
      };

      enable = lib.mkEnableOption "git, a distributed version control system";

      package = lib.mkPackageOption pkgs "git" {
        example = "gitFull";
      };

      attributes = lib.mkOption {
        default = "";

        description = ''
          Assign git attributes to files (one pattern per line):

              PATTERN1 ATTR1 ATTR2 ...

          Blank lines and lines beginning with # are ignored. See
          {manpage}`gitattributes(5)` for more information.
        '';

        example = "*.pdf diff=pdf";
        type = lib.types.lines;
      };

      lfs = {
        enable = lib.mkEnableOption "git-lfs (Large File Storage)";
        package = lib.mkPackageOption pkgs "git-lfs" { };
        enablePureSSHTransfer = lib.mkEnableOption "Enable pure SSH transfer in server side by adding git-lfs-transfer to environment.systemPackages";
      };

      prompt = {
        enable = lib.mkEnableOption "automatically sourcing git-prompt.sh. This does not change $PS1; it simply provides relevant utility functions";
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      environment.etc.gitattributes = lib.mkIf (cfg.attributes != "") {
        text = cfg.attributes + "\n";
      };

      environment.etc.gitconfig = lib.mkIf (cfg.config != [ ]) {
        text = lib.concatMapStringsSep "\n" lib.generators.toGitINI cfg.config;
      };

      environment.systemPackages = [ cfg.package ];
    })
    (lib.mkIf (cfg.enable && cfg.lfs.enable) {
      environment.systemPackages = lib.mkMerge [
        [ cfg.lfs.package ]
        (lib.mkIf cfg.lfs.enablePureSSHTransfer [ pkgs.git-lfs-transfer ])
      ];

      programs.git.config = {
        filter.lfs = {
          clean = "git-lfs clean -- %f";
          process = "git-lfs filter-process";
          required = true;
          smudge = "git-lfs smudge -- %f";
        };
      };
    })
    (lib.mkIf (cfg.enable && cfg.prompt.enable) {
      environment.interactiveShellInit = ''
        source ${cfg.package}/share/bash-completion/completions/git-prompt.sh
      '';
    })
  ];

  meta.maintainers = [ lib.maintainers.mushrowan ];
}
