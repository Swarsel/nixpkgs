{
  lib,
  haskellPackages,
}:

let
  withEnv =
    env:
    haskellPackages.mkDerivation {
      inherit env;
      pname = "puppy";
      version = "1.0.0";
      src = null;
      license = null;
    };

  failures = lib.runTests {
    testCanSetEnv = {
      expected = "DOGGY";

      expr =
        (withEnv {
          PUPPY = "DOGGY";
        }).drvAttrs.PUPPY;
    };

    testCanSetEnvMultiple = {
      expected = {
        PUPPY = "DOGGY";
        SILLY = "GOOFY";
      };

      expr =
        let
          env =
            (withEnv {
              PUPPY = "DOGGY";
              SILLY = "GOOFY";
            }).drvAttrs;
        in
        {
          inherit (env) PUPPY SILLY;
        };
    };

    testCanSetEnvPassthru = {
      expected = "DOGGY";

      expr =
        (withEnv {
          PUPPY = "DOGGY";
        }).passthru.env.PUPPY;
    };
  };
in
# TODO: Use `lib.debug.throwTestFailures`: https://github.com/NixOS/nixpkgs/pull/416207
lib.optional (failures != [ ]) (throw "${lib.generators.toPretty { } failures}")
