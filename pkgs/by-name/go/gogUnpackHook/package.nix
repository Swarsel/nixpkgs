{
  lib,
  file-rename,
  innoextract,
  makeSetupHook,
}:

makeSetupHook {
  propagatedBuildInputs = [
    innoextract
    file-rename
  ];

  name = "gog-unpack-hook";
  meta.license = lib.licenses.mit;
} ./gog-unpack.sh
