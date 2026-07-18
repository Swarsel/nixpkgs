{
  lib,
  buildEnv,
  makeBinaryWrapper,
  typst,
  typstPackages,
}:

lib.makeOverridable (
  { ... }@typstPkgs:
  {
    extraWrapperArgs ? [ ],
    fonts ? [ ],
    packages ? (ps: [ ]),
  }:
  buildEnv {
    inherit (typst) meta;
    nativeBuildInputs = [ makeBinaryWrapper ];

    postBuild = ''
      export TYPST_LIB_DIR="$out/lib/typst/packages"
      mkdir -p $TYPST_LIB_DIR

      mv $out/lib/typst-packages $TYPST_LIB_DIR/preview

      cp -r ${typst}/share $out/share
      mkdir -p $out/bin

      TYPST_FONT_PATHS=${lib.escapeShellArg (lib.concatStringsSep ":" fonts)}

      makeWrapper "${lib.getExe typst}" "$out/bin/typst" \
        --set TYPST_PACKAGE_CACHE_PATH $TYPST_LIB_DIR \
        ''${TYPST_FONT_PATHS:+--set TYPST_FONT_PATHS "$TYPST_FONT_PATHS"} \
        ${lib.escapeShellArgs extraWrapperArgs}
    '';

    name = "${typst.name}-env";

    paths = lib.foldl' (acc: p: acc ++ lib.singleton p ++ p.propagatedBuildInputs) [ ] (
      packages typstPkgs
    );

    pathsToLink = [ "/lib/typst-packages" ];
  }
) typstPackages
