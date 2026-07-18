# Tests the `projectReferences = [ ... ];` feature of buildDotnetModule.
# The `library` derivation exposes a .nupkg, which is then consumed by the `application` derivation.
# https://nixos.org/manual/nixpkgs/unstable/index.html#packaging-a-dotnet-application

{
  lib,
  buildPackages, # buildDotnetModule
  dotnet-sdk,
  runCommand,
}:

let
  inherit (buildPackages) buildDotnetModule;

  nugetDeps = ./nuget-deps.json;

  # Specify the TargetFramework via an environment variable so that we don't
  # have to update the .csproj files when updating dotnet-sdk
  TargetFramework = "net${lib.versions.majorMinor (lib.getVersion dotnet-sdk)}";

  library = buildDotnetModule {
    inherit nugetDeps;
    src = ./library;
    env.TargetFramework = TargetFramework;
    name = "project-references-test-library";
    packNupkg = true;
  };

  application = buildDotnetModule {
    inherit nugetDeps;
    src = ./application;
    env.TargetFramework = TargetFramework;
    name = "project-references-test-application";
    projectReferences = [ library ];
  };
in

runCommand "project-references-test" { } ''
  ${application}/bin/Application
  mkdir $out
''
