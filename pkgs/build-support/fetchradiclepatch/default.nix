{
  lib,
  fetchFromRadicle,
  jq,
}:

lib.makeOverridable (
  {
    revision,
    nativeBuildInputs ? [ ],
    postFetch ? "",
    ...
  }@args:

  assert
    (!args ? rev && !args ? tag) || throw "fetchRadiclePatch does not accept `rev` or `tag` arguments.";

  fetchFromRadicle (
    {
      nativeBuildInputs = [ jq ] ++ nativeBuildInputs;
      leaveDotGit = true;

      postFetch = ''
        { read -r head; read -r base; } < <(jq -r '.oid, .base' $out/0)
        git -C $out fetch --depth=1 "$url" "$base" "$head"
        git -C $out diff "$base" "$head" > patch
        rm -r $out
        mv patch $out
        ${postFetch}
      '';

      rev = revision;
    }
    // removeAttrs args [
      "revision"
      "postFetch"
      "nativeBuildInputs"
      "leaveDotGit"
    ]
  )
  // {
    inherit revision;
  }
)
