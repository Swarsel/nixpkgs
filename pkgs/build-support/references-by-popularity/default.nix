{
  coreutils,
  python3,
  runCommand,
}:
# Write the references of `path' to a file, in order of how "popular" each
# reference is. Nix 2 only.
path:
runCommand "closure-paths"
  {
    nativeBuildInputs = [
      coreutils
      python3
    ];

    __structuredAttrs = true;
    exportReferencesGraph.graph = path;
    preferLocalBuild = true;
  }
  ''
    python3 ${./closure-graph.py} "$NIX_ATTRS_JSON_FILE" graph > ''${outputs[out]}
  ''
