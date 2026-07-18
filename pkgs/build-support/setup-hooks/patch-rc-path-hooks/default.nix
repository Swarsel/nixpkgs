{
  lib,
  callPackage,
  gnused,
  makeSetupHook,
}:
let
  tests = import ./test { inherit callPackage; };
in
{
  patchRcPathBash = makeSetupHook {
    name = "patch-rc-path-bash";

    passthru.tests = {
      inherit (tests) test-bash;
    };

    meta = {
      description = "Setup-hook to inject source-time PATH prefix to a Bash/Ksh/Zsh script";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ ShamrockLee ];
    };
  } ./patch-rc-path-bash.sh;

  patchRcPathCsh = makeSetupHook {
    name = "patch-rc-path-csh";

    substitutions = {
      sed = "${gnused}/bin/sed";
    };

    passthru.tests = {
      inherit (tests) test-csh;
    };

    meta = {
      description = "Setup-hook to inject source-time PATH prefix to a Csh script";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ ShamrockLee ];
    };
  } ./patch-rc-path-csh.sh;

  patchRcPathFish = makeSetupHook {
    name = "patch-rc-path-fish";

    passthru.tests = {
      inherit (tests) test-fish;
    };

    meta = {
      description = "Setup-hook to inject source-time PATH prefix to a Fish script";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ ShamrockLee ];
    };
  } ./patch-rc-path-fish.sh;

  patchRcPathPosix = makeSetupHook {
    name = "patch-rc-path-posix";

    substitutions = {
      sed = "${gnused}/bin/sed";
    };

    passthru.tests = {
      inherit (tests) test-posix;
    };

    meta = {
      description = "Setup-hook to inject source-time PATH prefix to a POSIX shell script";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ ShamrockLee ];
    };
  } ./patch-rc-path-posix.sh;
}
