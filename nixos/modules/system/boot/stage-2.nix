{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let

  useHostResolvConf = config.networking.resolvconf.enable && config.networking.useHostResolvConf;

  bootStage2 = pkgs.replaceVarsWith {
    isExecutable = true;

    replacements = {
      inherit (config.boot) systemdExecutable stage2Greeting;
      inherit useHostResolvConf;
      inherit (config.system.build) earlyMountScript;
      nixStoreMountOpts = lib.concatStringsSep " " (map lib.escapeShellArg config.boot.nixStoreMountOpts);

      path = lib.makeBinPath (
        [
          pkgs.coreutils
          pkgs.util-linux
        ]
        ++ lib.optional useHostResolvConf pkgs.openresolv
      );

      postBootCommands = pkgs.writeText "local-cmds" ''
        ${config.boot.postBootCommands}
      '';

      shell = "${pkgs.bash}/bin/bash";
      systemConfig = null; # replaced in ../activation/top-level.nix
    };

    src = ./stage-2-init.sh;
  };

in

{
  imports = [
    (lib.mkRemovedOptionModule
      [
        "boot"
        "readOnlyNixStore"
      ]
      "Please use the `boot.nixStoreMountOpts' option to define mount options for the Nix store, including 'ro'"
    )
  ];

  options = {

    boot = {

      extraSystemdUnitPaths = mkOption {
        default = [ ];

        description = ''
          Additional paths that get appended to the SYSTEMD_UNIT_PATH environment variable
          that can contain mutable unit files.
        '';

        type = types.listOf types.str;
      };

      nixStoreMountOpts = mkOption {
        default = [
          "ro"
          "nodev"
          "nosuid"
        ];

        description = ''
          Defines the mount options used on a bind mount for the {file}`/nix/store`.
          This affects the whole system except the nix store daemon, which will undo the bind mount.

          `ro` enforces immutability of the Nix store.
          The store daemon should already not put device mappers or suid binaries in the store,
          meaning `nosuid` and `nodev` enforce what should already be the case.
        '';

        type = types.listOf types.nonEmptyStr;
      };

      postBootCommands = mkOption {
        default = "";

        description = ''
          Shell commands to be executed just before systemd is started.
        '';

        example = "rm -f /var/log/messages";
        type = types.lines;
      };

      stage2Greeting = mkOption {
        default = "<<< ${config.system.nixos.distroName} Stage 2 >>>";
        defaultText = literalExpression ''"<<< ''${config.system.nixos.distroName} Stage 2 >>>"'';

        description = ''
          The greeting message displayed during NixOS stage 2 boot.
        '';

        type = types.str;
      };

      systemdExecutable = mkOption {
        default = "/run/current-system/systemd/lib/systemd/systemd";

        description = ''
          The program to execute to start systemd.
        '';

        type = types.str;
      };
    };

  };

  config = {

    system.build.bootStage2 = bootStage2;
  };
}
