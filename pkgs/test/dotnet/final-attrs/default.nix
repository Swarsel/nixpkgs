{
  lib,
  buildPackages, # buildDotnetModule
  dotnet-sdk,
  runCommand,
  testers,
}:
let
  copyrightString = "Original Copyright";
  originalCopyright = builtins.toFile "original-copyright.txt" copyrightString;
  overridenCopyright = builtins.toFile "overridden-copyright.txt" (
    copyrightString + " with override!"
  );

  inherit (buildPackages) buildDotnetModule;

  app-recursive = buildDotnetModule (finalAttrs: {
    src = ../structured-attrs/src;
    env.TargetFramework = "net${lib.versions.majorMinor (lib.getVersion dotnet-sdk)}";
    __structuredAttrs = true;
    dotnetFlags = [ "--property:Copyright=${finalAttrs.passthru.copyrightString}" ];
    name = "final-attrs-rec-test-application";
    nugetDeps = ../structured-attrs/nuget-deps.json;

    passthru = {
      inherit copyrightString;
    };
  });

  app-const = buildDotnetModule {
    src = ../structured-attrs/src;
    env.TargetFramework = "net${lib.versions.majorMinor (lib.getVersion dotnet-sdk)}";
    __structuredAttrs = true;
    dotnetFlags = [ "--property:Copyright=${copyrightString}" ];
    name = "final-attrs-const-test-application";
    nugetDeps = ../structured-attrs/nuget-deps.json;

    passthru = {
      inherit copyrightString;
    };
  };

  override =
    app:
    app.overrideAttrs (previousAttrs: {
      passthru = previousAttrs.passthru // {
        copyrightString = previousAttrs.passthru.copyrightString + " with override!";
      };
    });

  run =
    name: app:
    runCommand name { } ''
      ${app}/bin/Application >"$out"
    '';
in
{
  check-output = testers.testEqualContents {
    actual = run "dotnet-final-attrs-test-rec-output" app-recursive;
    assertion = "buildDotnetModule produces the expected output when called with a recursive function";
    expected = originalCopyright;
  };

  output-matches-const = testers.testEqualContents {
    actual = run "dotnet-final-attrs-test-rec" app-recursive;
    assertion = "buildDotnetModule produces the same output when called with attrs or a recursive function";
    expected = run "dotnet-final-attrs-test-const" app-const;
  };

  override-has-no-effect = testers.testEqualContents {
    actual = run "dotnet-final-attrs-test-override-const-output" (override app-const);
    assertion = "buildDotnetModule produces the expected output when called with a recursive function";
    expected = originalCopyright;
  };

  override-modifies-output = testers.testEqualContents {
    actual = run "dotnet-final-attrs-test-override-rec-output" (override app-recursive);
    assertion = "buildDotnetModule produces the expected output when called with a recursive function";
    expected = overridenCopyright;
  };
}
