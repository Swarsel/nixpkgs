{
  pkgs,
  ...
}:

pkgs.testers.nixosTest {
  interactive.nodes.machine = {
    environment.systemPackages = [ pkgs.binutils ];
    virtualisation.graphics = false;
  };

  interactive.sshBackdoor.enable = true;
  name = "felix86";

  nodes.machine =
    {
      config,
      pkgs,
      ...
    }:
    {
      boot.binfmt.emulatedSystems = [ "riscv64-linux" ];

      environment.systemPackages = [
        pkgs.pkgsCross.riscv64.felix86
      ];
    };

  testScript =
    # python
    ''
      machine.wait_for_unit("multi-user.target")
      machine.succeed("felix86 --help")
    '';
}
