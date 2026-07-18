{
  lib,
  buildPackages, # buildDotnetModule, dotnet-runtime
  dotnet-sdk,
  removeReferencesTo,
  runCommand,
  testers,
}:
let
  inherit (buildPackages) buildDotnetModule dotnet-runtime;

  app = buildDotnetModule {
    src = ./src;
    env.TargetFramework = "net${lib.versions.majorMinor (lib.getVersion dotnet-sdk)}";
    name = "use-dotnet-from-env-test-application";
    nugetDeps = ./nuget-deps.json;
    useDotnetFromEnv = true;
  };

  appWithoutFallback = app.overrideAttrs (oldAttrs: {
    nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [
      removeReferencesTo
    ];

    postFixup = (oldAttrs.postFixup or "") + ''
      remove-references-to -t ${dotnet-runtime} "$out/bin/Application"
    '';
  });

  runtimeVersion = lib.head (lib.splitString "-" (lib.getVersion dotnet-runtime));
  runtimeVersionFile = builtins.toFile "dotnet-version.txt" runtimeVersion;
in
{
  fallback = testers.testEqualContents {
    actual = runCommand "use-dotnet-from-env-fallback-test" { } ''
      ${app}/bin/Application >"$out"
    '';

    assertion = "buildDotnetModule sets fallback DOTNET_ROOT in wrapper";
    expected = runtimeVersionFile;
  };

  use-dotnet-path-env = testers.testEqualContents {
    actual = runCommand "use-dotnet-from-env-path-test" { dotnetRuntime = dotnet-runtime; } ''
      PATH=$dotnetRuntime/bin''${PATH+:}$PATH ${appWithoutFallback}/bin/Application >"$out"
    '';

    assertion = "buildDotnetModule uses DOTNET_ROOT from dotnet in PATH in wrapper";
    expected = runtimeVersionFile;
  };

  # NB assumes that without-fallback above to passes.
  use-dotnet-root-env = testers.testEqualContents {
    actual =
      runCommand "use-dotnet-from-env-root-test" { env.DOTNET_ROOT = "${dotnet-runtime}/share/dotnet"; }
        ''
          ${appWithoutFallback}/bin/Application >"$out"
        '';

    assertion = "buildDotnetModule uses DOTNET_ROOT from environment in wrapper";
    expected = runtimeVersionFile;
  };

  # Check that appWithoutFallback does not use fallback .NET runtime.
  without-fallback = testers.testBuildFailure (
    runCommand "use-dotnet-from-env-without-fallback-test" { } ''
      ${appWithoutFallback}/bin/Application >"$out"
    ''
  );
}
