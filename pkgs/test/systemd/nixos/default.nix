{
  lib,
  pkgs,
  ...
}:

let
  failures = lib.runTests {
    # Merging must lift non-list definitions to a list
    # if at least one of them is a list.
    test-unitOption-merging-list-non-list-append =
      let
        nixos = pkgs.nixos {
          system.stateVersion = lib.trivial.release;

          systemd.services.systemd-test-nixos = {
            serviceConfig = lib.mkMerge [
              { StateDirectory = "foo"; }
              { StateDirectory = [ "bar" ]; }
            ];
          };
        };
      in
      {
        expected = [
          "foo"
          "bar"
        ];

        expr = nixos.config.systemd.services.systemd-test-nixos.serviceConfig.StateDirectory;
      };

    # Merging two non-list definitions must still result in an error
    # about a conflicting definition.
    test-unitOption-merging-non-lists-conflict =
      let
        nixos = pkgs.nixos {
          system.stateVersion = lib.trivial.release;

          systemd.services.systemd-test-nixos = {
            serviceConfig = lib.mkMerge [
              { StateDirectory = "foo"; }
              { StateDirectory = "bar"; }
            ];
          };
        };
      in
      {
        expected = false;

        expr =
          (builtins.tryEval (nixos.config.systemd.services.systemd-test-nixos.serviceConfig.StateDirectory))
          .success;
      };
  };
in

lib.debug.throwTestFailures {
  inherit failures;
  description = "systemd unit tests";
}
