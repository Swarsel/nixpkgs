{
  lib,
  cacert,
  darcs,
  stdenvNoCC,
}:

lib.makeOverridable (
  lib.fetchers.withNormalizedHash { } (
    {
      # Repository to fetch
      url,
      context ? null,
      # Additional list of repositories specifying alternative download
      # location to be tried in order, if the prior repository failed to fetch.
      mirrors ? [ ],
      name ? "fetchdarcs",
      outputHash ? lib.fakeHash,
      outputHashAlgo ? null,
      rev ? null,
    }:

    stdenvNoCC.mkDerivation {
      inherit outputHash outputHashAlgo;

      inherit
        rev
        context
        name
        ;

      nativeBuildInputs = [
        cacert
        darcs
      ];

      builder = ./builder.sh;
      outputHashMode = "recursive";
      repositories = [ url ] ++ mirrors;
    }
  )
)
