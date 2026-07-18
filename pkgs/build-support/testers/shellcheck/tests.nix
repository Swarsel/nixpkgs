# Run:
#   nix-build -A tests.testers.shellcheck

{
  lib,
  testers,
}:
lib.recurseIntoAttrs {
  example-dir = testers.testBuildFailure' {
    drv = testers.shellcheck {
      src = ./src;
      name = "example-dir";
    };

    expectedBuilderExitCode = 123;

    expectedBuilderLogEntries = [
      ''
        echo $@
             ^-- SC2068 (error): Double quote array expansions to avoid re-splitting elements.
      ''
    ];
  };

  example-file = testers.testBuildFailure' {
    drv = testers.shellcheck {
      src = ./src/example.sh;
      name = "example-file";
    };

    expectedBuilderExitCode = 123;

    expectedBuilderLogEntries = [
      ''
        echo $@
             ^-- SC2068 (error): Double quote array expansions to avoid re-splitting elements.
      ''
    ];
  };
}
