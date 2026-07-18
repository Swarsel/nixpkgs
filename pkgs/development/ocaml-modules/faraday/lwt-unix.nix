{
  buildDunePackage,
  faraday,
  faraday-lwt,
  lwt,
}:

buildDunePackage {
  inherit (faraday) version src;
  pname = "faraday-lwt-unix";

  propagatedBuildInputs = [
    lwt
    faraday-lwt
  ];

  duneVersion = "3";

  meta = faraday.meta // {
    description = "Lwt + Unix support for Faraday";
  };
}
