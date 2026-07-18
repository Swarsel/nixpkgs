{
  lib,
  runCommand,
  zig,
}:
{
  pname,
  src,
  version,
  fetchAll ? false,
  hash ? lib.fakeHash,
  name ? "${pname}-${version}",
}:
runCommand "${name}-zig-deps"
  {
    inherit src fetchAll;
    nativeBuildInputs = [ zig ];
    outputHash = hash;
    outputHashAlgo = null;
    outputHashMode = "recursive";
  }
  ''
    export ZIG_GLOBAL_CACHE_DIR=$(mktemp -d)

    runHook unpackPhase

    cd $sourceRoot
    zig build --fetch''${fetchAll:+=all}

    mv $ZIG_GLOBAL_CACHE_DIR/p $out
  ''
