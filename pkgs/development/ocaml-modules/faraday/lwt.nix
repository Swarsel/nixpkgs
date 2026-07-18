{
  buildDunePackage,
  faraday,
  lwt,
}:

buildDunePackage {
  inherit (faraday) version src;
  pname = "faraday-lwt";

  propagatedBuildInputs = [
    faraday
    lwt
  ];

  duneVersion = "3";

  meta = faraday.meta // {
    description = "Lwt support for Faraday";
  };
}
