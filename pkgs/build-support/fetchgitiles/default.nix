{
  lib,
  fetchzip,
  repoRevToNameMaybe,
}:

lib.makeOverridable (
  {
    url,
    name ? repoRevToNameMaybe url (lib.revOrTag rev tag) "gitiles",
    rev ? null,
    tag ? null,
    ...
  }@args:

  assert (
    lib.xor (tag == null) (rev == null)
    || throw "fetchFromGitiles requires one of either `rev` or `tag` to be provided (not both)."
  );

  let
    realrev = (if tag != null then "refs/tags/" + tag else rev);
  in

  fetchzip (
    {
      inherit name;
      stripRoot = false;
      url = "${url}/+archive/${realrev}.tar.gz";
      meta.homepage = url;
    }
    // removeAttrs args [
      "url"
      "tag"
      "rev"
    ]
  )
  // {
    inherit rev tag;
  }
)
