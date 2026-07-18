{
  lib,
  expect,
  nixos,
  testers,
}:
let
  node-forbiddenDependencies-fail = nixos (
    { config, ... }:
    {
      boot.loader.grub.enable = false;
      documentation.enable = false;

      environment.etc."dev-dependency" = {
        text = "${expect.dev}";
      };

      fileSystems."/" = {
        device = "ignore-root-device";
        fsType = "none";
      };

      system.forbiddenDependenciesRegexes = [ "-dev$" ];
      # Don't do this in an actual config
      system.stateVersion = config.system.nixos.release;
    }
  );
  node-forbiddenDependencies-succeed = nixos (
    { config, ... }:
    {
      boot.loader.grub.enable = false;
      documentation.enable = false;

      fileSystems."/" = {
        device = "ignore-root-device";
        fsType = "none";
      };

      system.extraDependencies = [ expect.dev ];
      system.forbiddenDependenciesRegexes = [ "-dev$" ];
      # Don't do this in an actual config
      system.stateVersion = config.system.nixos.release;
    }
  );
in
lib.recurseIntoAttrs {
  test-forbiddenDependencies-fail = testers.testBuildFailure node-forbiddenDependencies-fail.config.system.build.toplevel;

  test-forbiddenDependencies-succeed =
    node-forbiddenDependencies-succeed.config.system.build.toplevel;
}
