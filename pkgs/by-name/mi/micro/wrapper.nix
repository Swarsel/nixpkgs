{
  lib,
  makeWrapper,
  micro,
  symlinkJoin,
  # configurable options
  extraPackages ? [ ],
}:

symlinkJoin {
  inherit (micro) pname version outputs;
  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    ${lib.concatMapStringsSep "\n" (
      output: "ln --verbose --symbolic --no-target-directory ${micro.${output}} \$${output}"
    ) (lib.remove "out" micro.outputs)}

    pushd $out/bin
    for f in *; do
      rm $f
      makeWrapper ${micro}/bin/$f $f \
        --prefix PATH ":" "${lib.makeBinPath extraPackages}"
    done
    popd
  '';

  name = "micro-wrapped-${micro.version}";
  paths = [ micro ];
  meta = micro.meta;
}
