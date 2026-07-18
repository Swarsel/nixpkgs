# You can specify some extra mirrors and a cache DB via options
{
  lib,
  monotone,
  stdenvNoCC,
  cacheDB ? "./mtn-checkout.db",
  defaultDBMirrors ? [ ],
}:

lib.fetchers.withNormalizedHash { } (
  # dbs is a list of strings, each is an url for sync
  # selector is mtn selector, like h:org.example.branch
  {
    branch,
    outputHash,
    outputHashAlgo,
    dbs ? [ ],
    name ? "mtn-checkout",
    selector ? "h:" + branch,
  }:

  stdenvNoCC.mkDerivation {
    inherit outputHash outputHashAlgo;

    inherit
      branch
      cacheDB
      name
      selector
      ;

    nativeBuildInputs = [ monotone ];
    builder = ./builder.sh;
    dbs = defaultDBMirrors ++ dbs;
    impureEnvVars = lib.fetchers.proxyImpureEnvVars;
    outputHashMode = "recursive";

  }
)
