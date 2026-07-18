{
  lib,
  fetchurl,
  buildDunePackage,
  fpath,
  re,
  testo,
  testo-diff,
}:

buildDunePackage {
  inherit (testo) version src;
  pname = "testo-util";

  propagatedBuildInputs = [
    fpath
    re
    testo-diff
  ];

  meta = testo.meta // {
    description = "Modules shared by testo, testo-lwt, etc";
  };
}
