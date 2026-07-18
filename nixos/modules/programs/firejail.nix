{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.firejail;

  wrappedBins =
    pkgs.runCommand "firejail-wrapped-binaries"
      {
        allowSubstitutes = false;
        preferLocalBuild = true;
        # take precedence over non-firejailed versions
        meta.priority = -1;
      }
      ''
        mkdir -p $out/bin
        mkdir -p $out/share/applications
        ${lib.concatStringsSep "\n" (
          lib.mapAttrsToList (
            command: value:
            let
              opts =
                if builtins.isAttrs value then
                  value
                else
                  {
                    desktop = null;
                    executable = value;
                    extraArgs = [ ];
                    profile = null;
                  };
              args = lib.escapeShellArgs (
                opts.extraArgs ++ (lib.optional (opts.profile != null) "--profile=${toString opts.profile}")
              );
            in
            ''
              cat <<_EOF >$out/bin/${command}
              #! ${pkgs.runtimeShell} -e
              exec /run/wrappers/bin/firejail ${args} -- ${toString opts.executable} "\$@"
              _EOF
              chmod 0755 $out/bin/${command}

              ${lib.optionalString (opts.desktop != null) ''
                substitute ${opts.desktop} $out/share/applications/$(basename ${opts.desktop}) \
                  --replace ${opts.executable} $out/bin/${command}
              ''}
            ''
          ) cfg.wrappedBinaries
        )}
      '';

in
{
  options.programs.firejail = {
    enable = lib.mkEnableOption "firejail, a sandboxing tool for Linux";

    wrappedBinaries = lib.mkOption {
      default = { };

      description = ''
        Wrap the binaries in firejail and place them in the global path.
      '';

      example = lib.literalExpression ''
        {
          firefox = {
            executable = "''${lib.getBin pkgs.firefox}/bin/firefox";
            profile = "''${pkgs.firejail}/etc/firejail/firefox.profile";
          };
          mpv = {
            executable = "''${lib.getBin pkgs.mpv}/bin/mpv";
            profile = "''${pkgs.firejail}/etc/firejail/mpv.profile";
          };
        }
      '';

      type = lib.types.attrsOf (
        lib.types.either lib.types.path (
          lib.types.submodule {
            options = {
              desktop = lib.mkOption {
                default = null;
                description = ".desktop file to modify. Only necessary if it uses the absolute path to the executable.";
                example = lib.literalExpression ''"''${pkgs.firefox}/share/applications/firefox.desktop"'';
                type = lib.types.nullOr lib.types.path;
              };

              executable = lib.mkOption {
                description = "Executable to run sandboxed";
                example = lib.literalExpression ''"''${lib.getBin pkgs.firefox}/bin/firefox"'';
                type = lib.types.path;
              };

              extraArgs = lib.mkOption {
                default = [ ];
                description = "Extra arguments to pass to firejail";
                example = [ "--private=~/.firejail_home" ];
                type = lib.types.listOf lib.types.str;
              };

              profile = lib.mkOption {
                default = null;
                description = "Profile to use";
                example = lib.literalExpression ''"''${pkgs.firejail}/etc/firejail/firefox.profile"'';
                type = lib.types.nullOr lib.types.path;
              };
            };
          }
        )
      );
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.firejail ] ++ [ wrappedBins ];

    security.wrappers.firejail = {
      group = "root";
      owner = "root";
      setuid = true;
      source = "${lib.getBin pkgs.firejail}/bin/firejail";
    };
  };

  meta.maintainers = with lib.maintainers; [ peterhoeg ];
}
