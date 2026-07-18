{ lib, callPackage }:

{
  cross-target = callPackage ./cross-target { };
  final-attrs = lib.recurseIntoAttrs (callPackage ./final-attrs { });
  nuget-deps = lib.recurseIntoAttrs (callPackage ./nuget-deps { });
  project-references = callPackage ./project-references { };
  structured-attrs = lib.recurseIntoAttrs (callPackage ./structured-attrs { });
  use-dotnet-from-env = lib.recurseIntoAttrs (callPackage ./use-dotnet-from-env { });
}
