{
  lib,
  buildBatExtrasPkg,
  coreutils,
  entr,
  less,
  withEntr ? true,
}:
buildBatExtrasPkg {
  dependencies = [
    less
    coreutils
  ]
  ++ lib.optional withEntr entr;

  name = "batwatch";
  meta.description = "Watch for changes in one or more files, and print them with bat";
}
