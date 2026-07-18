{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.liboping;
in
{
  options.programs.liboping = {
    enable = lib.mkEnableOption "liboping";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ liboping ];

    security.wrappers = lib.mkMerge (
      map
        (exec: {
          "${exec}" = {
            capabilities = "cap_net_raw+p";
            group = "root";
            owner = "root";
            source = "${pkgs.liboping}/bin/${exec}";
          };
        })
        [
          "oping"
          "noping"
        ]
    );
  };
}
