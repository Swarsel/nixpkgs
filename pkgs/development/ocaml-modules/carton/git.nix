{
  astring,
  bigstringaf,
  buildDunePackage,
  carton,
  carton-lwt,
  decompress,
  fmt,
  fpath,
  lwt,
  result,
}:

buildDunePackage {
  inherit (carton) version src postPatch;
  inherit (carton) meta;
  pname = "carton-git";

  propagatedBuildInputs = [
    carton
    carton-lwt
    bigstringaf
    lwt
    fpath
    result
    fmt
    decompress
    astring
  ];

  duneVersion = "3";
}
