{
  alcotest,
  buildDunePackage,
  ff-pbt,
  ff-sig,
  zarith,
}:

buildDunePackage {
  inherit (ff-sig) version src;
  pname = "ff";

  propagatedBuildInputs = [
    ff-sig
    zarith
  ];

  doCheck = true;

  checkInputs = [
    alcotest
    ff-pbt
  ];

  duneVersion = "3";

  meta = ff-sig.meta // {
    description = "OCaml implementation of Finite Field operations";
  };
}
