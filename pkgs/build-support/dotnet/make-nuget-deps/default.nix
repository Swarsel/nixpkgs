{
  lib,
  fetchNupkg,
  symlinkJoin,
}:
lib.makeOverridable (
  {
    name,
    installable ? false,
    nugetDeps ? null,
    sourceFile ? null,
  }:
  (symlinkJoin {
    name = "${name}-nuget-deps";

    paths =
      let
        loadDeps =
          if nugetDeps != null then
            nugetDeps
          else if lib.hasSuffix ".nix" sourceFile then
            assert (lib.isPath sourceFile);
            import sourceFile
          else
            { fetchNuGet }: map fetchNuGet (lib.importJSON sourceFile);
      in
      loadDeps {
        fetchNuGet = args: fetchNupkg (args // { inherit installable; });
      };
  })
  // {
    inherit sourceFile;
  }
)
