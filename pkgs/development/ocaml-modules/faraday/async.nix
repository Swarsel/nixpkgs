{
  async,
  buildDunePackage,
  faraday,
  core_unix ? null,
}:

buildDunePackage {
  inherit (faraday) version src;
  pname = "faraday-async";

  propagatedBuildInputs = [
    faraday
    core_unix
    async
  ];

  duneVersion = "3";
  minimalOCamlVersion = "4.08";

  meta = faraday.meta // {
    description = "Async support for Faraday";
  };
}
