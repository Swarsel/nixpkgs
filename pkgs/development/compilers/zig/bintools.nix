{
  lib,
  stdenv,
  makeWrapper,
  runCommand,
  zig,
}:
let
  targetPrefix = lib.optionalString (
    stdenv.hostPlatform != stdenv.targetPlatform
  ) "${stdenv.targetPlatform.config}-";
in
runCommand "zig-bintools-${zig.version}"
  {
    inherit (zig) version meta;
    inherit zig;
    pname = "zig-bintools";
    nativeBuildInputs = [ makeWrapper ];

    passthru = {
      inherit targetPrefix;
      isZig = true;
    };
  }
  ''
    mkdir -p $out/bin
    for tool in ar objcopy ranlib ld.lld; do
      makeWrapper "$zig/bin/zig" "$out/bin/$tool" \
        --add-flags "$tool" \
        --run "export ZIG_GLOBAL_CACHE_DIR=\$TMPDIR/zig-cache"
    done

    ln -s $out/bin/ld.lld $out/bin/ld
  ''
