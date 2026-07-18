{
  alcotest,
  buildDunePackage,
  cachet,
  lwt,
}:

buildDunePackage {
  inherit (cachet) src version;
  pname = "cachet-lwt";

  propagatedBuildInputs = [
    cachet
    lwt
  ];

  doCheck = true;
  checkInputs = [ alcotest ];

  meta = cachet.meta // {
    description = "A simple cache system for mmap and lwt";
  };
}
