{
  lib,
  stdenvNoCC,
  testers,
}:
# See https://nixos.org/manual/nixpkgs/unstable/#tester-testBuildFailurePrime
# or doc/build-helpers/testers.chapter.md
lib.makeOverridable (
  {
    drv,
    expectedBuilderExitCode ? 1,
    expectedBuilderLogEntries ? [ ],
    name ? "testBuildFailure-${drv.name}",
    script ? "",
  }:
  stdenvNoCC.mkDerivation (finalAttrs: {
    inherit name;
    inherit expectedBuilderExitCode expectedBuilderLogEntries;
    inherit script;
    strictDeps = true;
    nativeBuildInputs = [ finalAttrs.failed ];
    __structuredAttrs = true;
    buildCommandPath = ./build-command.sh;
    failed = testers.testBuildFailure drv;

    meta = {
      description = "Wrapper around testers.testBuildFailure to simplify common use cases";
      maintainers = [ lib.maintainers.connorbaker ];
    };
  })
)
