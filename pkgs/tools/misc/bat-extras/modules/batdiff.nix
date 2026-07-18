{
  lib,
  buildBatExtrasPkg,
  coreutils,
  delta,
  gitMinimal,
  less,
  withDelta ? true,
}:
buildBatExtrasPkg {
  dependencies = [
    less
    coreutils
    gitMinimal
  ]
  ++ lib.optional withDelta delta;

  name = "batdiff";
  meta.description = "Diff a file against the current git index, or display the diff between two files";
}
