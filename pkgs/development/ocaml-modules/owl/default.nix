{
  alcotest,
  buildDunePackage,
  ctypes,
  dune-configurator,
  npy,
  openblasCompat,
  owl-base,
  stdio,
}:

buildDunePackage {
  inherit (owl-base) version src meta;
  pname = "owl";

  buildInputs = [
    dune-configurator
    stdio
  ];

  propagatedBuildInputs = [
    ctypes
    openblasCompat
    owl-base
    npy
  ];

  doCheck = true;
  checkInputs = [ alcotest ];
}
