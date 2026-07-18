# Tests that `nugetDeps` in buildDotnetModule can handle various types.

{
  lib,
  buildPackages, # buildDotnetModule
  dotnet-sdk,
  runCommand,
}:

let
  inherit (lib)
    mapAttrs
    ;

  inherit (buildPackages)
    emptyDirectory
    buildDotnetModule
    ;

in
mapAttrs
  (
    name: nugetDeps:
    buildDotnetModule {
      inherit nugetDeps;
      name = "nuget-deps-${name}";

      unpackPhase = ''
        runHook preUnpack

        mkdir test
        cd test
        dotnet new console -o .
        ls -l

        runHook postUnpack
      '';
    }
  )
  {
    "derivation" = emptyDirectory;
    "json-file" = ./nuget-deps.json;
    "list" = [ emptyDirectory ];
    "nix-file" = ./nuget-deps.nix;
    "null" = null;
  }
