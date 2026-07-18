{
  lib,
  nixos,
  runCommand,
}:
let
  base = nixos {
    boot.loader.grub.enable = false;
    fileSystems."/".device = "/dev/null";

    programs.nix-required-mounts = {
      enable = true;
      presets.nvidia-gpu.enable = true;
    };

    services.userborn.enable = true;
    system.stateVersion = lib.trivial.release;
  };
  machine = base.extendModules {
    modules = [ { hardware.graphics.enable = true; } ];
  };
in
runCommand "nix-required-mounts-eval-nvidia-gpu-preset" { } ''
  echo "Successfully evaluated ${base.config.system.build.toplevel}"
  echo "Successfully evaluated ${machine.config.system.build.toplevel}"
  echo "This means that combining nix-required-mounts with userborn no longer causes infinite recursion (#488199)"
  touch $out
''
