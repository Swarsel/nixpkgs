{
  lib,
  fetchgit,
  formats,
}:
let
  inherit (lib)
    concatStrings
    listToAttrs
    makeOverridable
    mapAttrsToList
    nameValuePair
    ;
  json = formats.json { };
in
rec {

  # Make packaging helpers from swiftpm2nix generated output.
  helpers =
    generated:
    let
      inherit (import generated) workspaceStateFile hashes;
      workspaceState = lib.importJSON workspaceStateFile;
      pinFile = mkPinFile workspaceState;
    in
    rec {

      # Configure phase snippet for use in packaging.
      configure = ''
        mkdir -p .build/checkouts
        ln -sf ${pinFile} ./Package.resolved
        install -m 0600 ${workspaceStateFile} ./.build/workspace-state.json
      ''
      + concatStrings (
        mapAttrsToList (name: src: ''
          ln -s '${src}' '.build/checkouts/${name}'
        '') sources
      )
      + ''
        # Helper that makes a swiftpm dependency mutable by copying the source.
        swiftpmMakeMutable() {
          local orig="$(readlink .build/checkouts/$1)"
          rm .build/checkouts/$1
          cp -r "$orig" .build/checkouts/$1
          chmod -R u+w .build/checkouts/$1
        }
      '';

      # Create fetch expressions for dependencies.
      sources = listToAttrs (
        map (
          dep:
          nameValuePair dep.subpath (fetchgit {
            fetchSubmodules = true;
            rev = dep.state.checkoutState.revision;
            sha256 = hashes.${dep.subpath};
            url = dep.packageRef.location;
          })
        ) workspaceState.object.dependencies
      );

    };

  # Derive a pin file from workspace state.
  mkPinFile =
    workspaceState:
    assert workspaceState.version >= 5 && workspaceState.version <= 6;
    json.generate "Package.resolved" {
      version = 1;

      object.pins = map (dep: {
        package = dep.packageRef.name;
        repositoryURL = dep.packageRef.location;
        state = dep.state.checkoutState;
      }) workspaceState.object.dependencies;
    };

}
