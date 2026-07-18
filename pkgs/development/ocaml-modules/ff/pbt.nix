{
  alcotest,
  buildDunePackage,
  ff-sig,
  zarith,
}:

buildDunePackage {
  inherit (ff-sig) version src;
  pname = "ff-pbt";

  propagatedBuildInputs = [
    zarith
    ff-sig
  ];

  doCheck = true;

  checkInputs = [
    alcotest
  ];

  duneVersion = "3";
  minimalOCamlVersion = "4.08";

  meta = ff-sig.meta // {
    description = "Property based testing library for finite fields over the package ff-sig";
  };
}
