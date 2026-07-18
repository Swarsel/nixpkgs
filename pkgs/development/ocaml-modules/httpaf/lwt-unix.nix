{
  buildDunePackage,
  faraday-lwt-unix,
  httpaf,
  lwt,
}:

buildDunePackage {
  inherit (httpaf) version src;
  pname = "httpaf-lwt-unix";

  propagatedBuildInputs = [
    faraday-lwt-unix
    httpaf
    lwt
  ];

  duneVersion = "3";
  minimalOCamlVersion = "4.08";

  meta = httpaf.meta // {
    description = "Lwt support for http/af";
  };
}
