{
  lib,
  stdenv,
  buildBatExtrasPkg,
  util-linux,
}:
buildBatExtrasPkg {
  dependencies = lib.optional stdenv.targetPlatform.isLinux util-linux;
  name = "batman";

  shellInit = {
    flags = [ "--export-env" ];
  };

  meta.description = "Read system manual pages (man) using bat as the manual page formatter";
}
