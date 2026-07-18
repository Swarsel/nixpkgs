{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.ghidra;
in
{
  options.programs.ghidra = {
    enable = lib.mkEnableOption "Ghidra, a software reverse engineering (SRE) suite of tools";
    package = lib.mkPackageOption pkgs "ghidra" { example = "ghidra-bin"; };

    gdb = lib.mkOption {
      default = true;

      description = ''
        Whether to add to gdbinit the python modules required to make Ghidra's debugger work.
      '';

      type = lib.types.bool;
    };
  };

  config = lib.mkIf cfg.enable {
    environment = {
      etc = lib.mkIf cfg.gdb {
        "gdb/gdbinit.d/ghidra-modules.gdb".text = with pkgs.python3.pkgs; ''
          python
          import sys
          [sys.path.append(p) for p in "${
            (makePythonPath [
              psutil
              protobuf
            ])
          }".split(":")]
          end
        '';
      };

      systemPackages = [ cfg.package ];
    };
  };

  meta.maintainers = with lib.maintainers; [ govanify ];
}
