{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.tcpdump;
in
{
  options = {
    programs.tcpdump = {
      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to configure a setcap wrapper for tcpdump.
          To use it, add your user to the `pcap` group.
        '';

        type = lib.types.bool;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    security.wrappers.tcpdump = {
      capabilities = "cap_net_raw+p";
      group = "pcap";
      owner = "root";
      permissions = "u+rx,g+x";
      source = lib.getExe pkgs.tcpdump;
    };

    users.groups.pcap = { };
  };
}
