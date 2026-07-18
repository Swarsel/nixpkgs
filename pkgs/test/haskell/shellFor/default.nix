{
  lib,
  cabal-install,
  haskellPackages,
  srcOnly,
  writeText,
}:

(haskellPackages.shellFor {
  nativeBuildInputs = [ cabal-install ];

  buildPhase = ''
    export HOME=$(mktemp -d)
    mkdir -p $HOME/.cabal
    touch $HOME/.cabal/config

    # Check that the extraDependencies.libraryHaskellDepends arg is correctly
    # picked up. This uses ghci to interpret a small Haskell program that uses
    # a package from extraDependencies.
    ghci <<EOF
    :set -XOverloadedStrings
    :m + Conduit
    runResourceT $ connect (yield "done") (sinkFile "outfile")
    EOF

    if [[ "done" != "$(cat outfile)" ]]; then
      echo "ERROR: extraDependencies appear not to be available in the environment"
      exit 1
    fi

    # Check packages arg
    cabal v2-build --offline --verbose constraints cereal --ghc-options="-O0 -j$NIX_BUILD_CORES"
  '';

  installPhase = ''
    touch $out
  '';

  # WARNING: When updating this, make sure that the libraries passed to
  # `extraDependencies` are not actually transitive dependencies of libraries in
  # `packages` above.  We explicitly want to test that it is possible to specify
  # `extraDependencies` that are not in the closure of `packages`.
  extraDependencies = p: { libraryHaskellDepends = [ p.conduit ]; };

  packages = p: [
    p.constraints
    p.cereal
  ];

  unpackPhase = ''
    sourceRoot=$(pwd)/scratch
    mkdir -p "$sourceRoot"
    cd "$sourceRoot"
    cp -r "${srcOnly haskellPackages.constraints}" constraints
    cp -r "${srcOnly haskellPackages.cereal}" cereal
    cp ${writeText "cabal.project" "packages: constraints cereal"} cabal.project
  '';
}).overrideAttrs
  (oldAttrs: {
    # `shellFor` adds a `buildCommand` (via `envFunc -> runCommandCC`), which
    # overrides custom phases. To ensure this test's phases run, we remove
    # that `buildCommand` from the derivation.
    buildCommand = null;

    meta =
      let
        oldMeta = oldAttrs.meta or { };
        oldMaintainers = oldMeta.maintainers or [ ];
        additionalMaintainers = with lib.maintainers; [ cdepillabout ];
        allMaintainers = oldMaintainers ++ additionalMaintainers;
      in
      oldMeta
      // {
        inherit (cabal-install.meta) platforms;
        maintainers = allMaintainers;
      };
  })
