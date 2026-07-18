{
  buildDunePackage,
  lwt,
  zmq,
}:

buildDunePackage {
  inherit (zmq) version src meta;
  pname = "zmq-lwt";

  propagatedBuildInputs = [
    zmq
    lwt
  ];
}
