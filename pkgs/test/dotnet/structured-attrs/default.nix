{
  lib,
  buildPackages, # buildDotnetModule
  dotnet-sdk,
  runCommand,
  testers,
}:
let
  # Note: without structured attributes, we can’t use derivation arguments that
  # contain spaces unambiguously because arguments are passed as space-separated
  # environment variables.
  copyrightString = "Public domain 🅮";

  inherit (buildPackages) buildDotnetModule;

  app = buildDotnetModule {
    src = ./src;
    env.TargetFramework = "net${lib.versions.majorMinor (lib.getVersion dotnet-sdk)}";
    __structuredAttrs = true;
    dotnetFlags = [ "--property:Copyright=${copyrightString}" ];
    name = "structured-attrs-test-application";
    nugetDeps = ./nuget-deps.json;
  };
in
{
  check-output = testers.testEqualContents {
    actual = runCommand "dotnet-structured-attrs-test" { } ''
      ${app}/bin/Application >"$out"
    '';

    assertion = "buildDotnetModule sets AssemblyCopyrightAttribute with structured attributes";
    expected = builtins.toFile "expected-copyright.txt" copyrightString;
  };

  no-structured-attrs = testers.testBuildFailure (
    app.overrideAttrs {
      __structuredAttrs = false;
    }
  );
}
