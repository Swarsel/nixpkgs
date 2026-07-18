{
  alcotest,
  buildDunePackage,
  eio,
  eio_main,
  tar,
}:

buildDunePackage {
  inherit (tar) version src doCheck;
  pname = "tar-eio";

  propagatedBuildInputs = [
    tar
    eio
  ];

  checkInputs = [
    alcotest
    eio_main
  ];

  minimalOCamlVersion = "5.1";

  meta = tar.meta // {
    description = "Decode and encode tar format files using Eio";
  };
}
