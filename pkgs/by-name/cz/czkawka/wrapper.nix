{
  lib,
  czkawka,
  makeWrapper,
  symlinkJoin,
  # configurable options
  extraPackages ? [ ],
}:

symlinkJoin {
  inherit (czkawka) pname version outputs;
  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    ${lib.concatMapStringsSep "\n" (
      output: "ln --symbolic --no-target-directory ${czkawka.${output}} \$${output}"
    ) (lib.remove "out" czkawka.outputs)}

    pushd $out/bin
    for f in *; do
      rm -v $f
      makeWrapper ${lib.getBin czkawka}/bin/$f $out/bin/$f \
        --prefix PATH ":" "${lib.makeBinPath extraPackages}"
    done
    popd
  '';

  name = "czkawka-wrapped-${czkawka.version}";
  paths = [ czkawka ];
  meta = czkawka.meta;
}
